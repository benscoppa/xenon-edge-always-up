import asyncio

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer

from winrt.windows.media.control import (
    GlobalSystemMediaTransportControlsSessionManager,
)

from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer, QUrl
from winrt.windows.storage.streams import DataReader


class MediaService(QObject):
    titleChanged = Signal()
    artistChanged = Signal()
    playingChanged = Signal()
    positionChanged = Signal()
    durationChanged = Signal()
    seekEnabledChanged = Signal()
    artworkChanged = Signal()

    def __init__(self):
        super().__init__()

        self._title = ""
        self._artist = ""

        self._is_playing = False

        self._position = 0.0
        self._duration = 0.0

        self._manager = None
        self._session = None

        self._refreshing = False

        self._seek_enabled = False

        self._artwork_path = ""

        # Windows media information sync
        self._timer = QTimer(self)
        self._timer.setInterval(500)
        self._timer.timeout.connect(self._refresh_wrapper)

        self._artwork_path = ""

        self._artwork_dir = (
            Path(__file__).resolve().parent.parent
            / ".cache"
        )

        self._artwork_dir.mkdir(exist_ok=True)

        self._artwork_file = self._artwork_dir / "album_art.jpg"

    # --------------------------------------------------
    # QML properties
    # --------------------------------------------------

    @Property(str, notify=titleChanged)
    def title(self):
        return self._title or ""

    @Property(str, notify=artistChanged)
    def artist(self):
        return self._artist or ""

    @Property(bool, notify=playingChanged)
    def isPlaying(self):
        return self._is_playing

    @Property(float, notify=positionChanged)
    def position(self):
        return self._position

    @Property(float, notify=durationChanged)
    def duration(self):
        return self._duration

    @Property(bool, notify=seekEnabledChanged)
    def seekEnabled(self):
        return self._seek_enabled

    @Property(str, notify=artworkChanged)
    def artworkPath(self):
        return self._artwork_path

    # --------------------------------------------------
    # Initialization
    # --------------------------------------------------

    async def initialize(self):
        self._manager = await (
            GlobalSystemMediaTransportControlsSessionManager.request_async()
        )

        await self.refresh()

        self._timer.start()

    # --------------------------------------------------
    # Media refresh
    # --------------------------------------------------

    def _refresh_wrapper(self):
        if not self._refreshing:
            asyncio.create_task(self.refresh())

    async def refresh(self):
        if self._manager is None or self._refreshing:
            return

        self._refreshing = True

        try:
            self._session = self._manager.get_current_session()

            if self._session is None:
                self._clear_media()
                return

            media = await self._session.try_get_media_properties_async()

            await self._update_artwork(media)

            playback = self._session.get_playback_info()

            new_seek_enabled = playback.controls.is_playback_position_enabled

            if new_seek_enabled != self._seek_enabled:
                self._seek_enabled = new_seek_enabled
                self.seekEnabledChanged.emit()

            timeline = self._session.get_timeline_properties()

            new_title = media.title or ""
            new_artist = media.artist or ""

            if new_title != self._title:
                self._title = new_title
                self.titleChanged.emit()

            if new_artist != self._artist:
                self._artist = new_artist
                self.artistChanged.emit()

            # GSMTC playback status 4 = Playing
            new_is_playing = playback.playback_status == 4

            if new_is_playing != self._is_playing:
                self._is_playing = new_is_playing
                self.playingChanged.emit()

            new_position = timeline.position.total_seconds()
            new_duration = timeline.end_time.total_seconds()

            # Windows can briefly report a 0-length timeline while changing tracks.
            # Ignore that transient state instead of sending it to QML.
            if new_duration > 0:
                if new_duration != self._duration:
                    self._duration = new_duration
                    self.durationChanged.emit()

                if new_position != self._position:
                    self._position = new_position
                    self.positionChanged.emit()

        except Exception as error:
            print("Media refresh error:", error)

        finally:
            self._refreshing = False

    def _clear_media(self):
        if self._title:
            self._title = ""
            self.titleChanged.emit()

        if self._artist:
            self._artist = ""
            self.artistChanged.emit()

        if self._is_playing:
            self._is_playing = False
            self.playingChanged.emit()

        if self._position != 0:
            self._position = 0
            self.positionChanged.emit()

        if self._duration != 0:
            self._duration = 0
            self.durationChanged.emit()

        if self._artwork_path:
            self._artwork_path = ""
            self.artworkChanged.emit()

    async def _update_artwork(self, media):
        thumbnail = media.thumbnail

        if thumbnail is None:
            if self._artwork_path != "":
                self._artwork_path = ""
                self.artworkChanged.emit()

            return

        try:
            stream = await thumbnail.open_read_async()

            size = int(stream.size)

            if size <= 0:
                return

            reader = DataReader(stream)

            await reader.load_async(size)

            data = bytearray(size)
            reader.read_bytes(data)

            reader.detach_stream()
            reader.close()
            stream.close()

            self._artwork_file.write_bytes(data)

            # Add a query value so QML reloads the file when the song changes.
            file_url = QUrl.fromLocalFile(
                str(self._artwork_file)
            ).toString()

            new_path = file_url + "?v=" + str(hash(media.title))

            if new_path != self._artwork_path:
                self._artwork_path = new_path
                self.artworkChanged.emit()

        except Exception as error:
            print("Artwork error:", error)

    # --------------------------------------------------
    # Media controls
    # --------------------------------------------------

    @Slot()
    def toggle_play_pause(self):
        if self._session is not None:
            asyncio.create_task(self._toggle_play_pause())

    async def _toggle_play_pause(self):
        await self._session.try_toggle_play_pause_async()

    @Slot()
    def previous(self):
        if self._session is not None:
            asyncio.create_task(self._previous())

    async def _previous(self):
        await self._session.try_skip_previous_async()

    @Slot()
    def next(self):
        if self._session is not None:
            asyncio.create_task(self._next())

    async def _next(self):
        await self._session.try_skip_next_async()

    @Slot(float)
    def seekTo(self, seconds):
        if self._session is not None:
            asyncio.create_task(self._seek(seconds))


    async def _seek(self, seconds):
        try:
            playback = self._session.get_playback_info()
            controls = playback.controls

            print(
                "Seek enabled:",
                controls.is_playback_position_enabled
            )

            ticks = int(seconds * 10_000_000)

            print("Seeking to:", seconds, "seconds")
            print("Ticks:", ticks)

            success = await self._session.try_change_playback_position_async(
                ticks
            )

            print("Seek returned:", success)

        except Exception as error:
            print("Seek error:", error)