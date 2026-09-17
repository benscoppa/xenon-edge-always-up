import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    color: "#20242c"
    clip: true

    property real progressValue: 0

    property real durationValue:
        mediaService.duration > 0
        ? mediaService.duration
        : 1

    property double lastTickMs: 0

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)

        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Component.onCompleted: {
        root.progressValue = mediaService.position || 0
    }

    // --------------------------------------------------
    // Updates coming from Python
    // --------------------------------------------------

    Connections {
        target: mediaService

        function onPositionChanged() {
            // Don't fight the user while they're dragging the slider
            if (progressSlider.pressed)
                return

            var difference =
                Math.abs(mediaService.position - root.progressValue)

            if (difference > 1.25 || !mediaService.isPlaying) {
                root.progressValue = mediaService.position
            }
        }

        function onPlayingChanged() {
            if (mediaService.isPlaying) {
                root.lastTickMs = Date.now()
            } else {
                root.lastTickMs = 0
                root.progressValue = mediaService.position
            }
        }
    }

    // --------------------------------------------------
    // Smooth local playback clock
    // --------------------------------------------------

    Timer {
        id: playbackTimer

        interval: 100
        repeat: true
        running: mediaService.isPlaying

        onTriggered: {
            if (progressSlider.pressed)
                return

            var now = Date.now()

            if (root.lastTickMs === 0) {
                root.lastTickMs = now
                return
            }

            var elapsedSeconds =
                (now - root.lastTickMs) / 1000.0

            root.lastTickMs = now

            root.progressValue = Math.min(
                root.durationValue,
                root.progressValue + elapsedSeconds
            )
        }
    }

    // --------------------------------------------------
    // Theme background
    // --------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: "#20242c"
    }

    // --------------------------------------------------
    // Album artwork
    // --------------------------------------------------

    Item {
        id: albumArt

        width: 300
        height: 300

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 80

        Rectangle {
            anchors.fill: parent

            radius: 12
            color: "#181B20"

            visible: mediaService.artworkPath.length === 0

            Image {
                anchors.centerIn: parent

                width: 120
                height: 120

                source: "../assets/icons/media/music-note.svg"
                fillMode: Image.PreserveAspectFit

                sourceSize.width: width * 4
                sourceSize.height: height * 4

                smooth: true
                mipmap: true
            }
        }

        Image {
            anchors.fill: parent

            source: mediaService.artworkPath

            fillMode: Image.PreserveAspectCrop
            smooth: true

            visible: mediaService.artworkPath.length > 0
        }
    }

    // --------------------------------------------------
    // Track title
    // --------------------------------------------------

    Item {
        id: titleContainer

        width: parent.width - 80
        height: 40

        anchors.top: albumArt.bottom
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter

        clip: true

        property bool needsScroll:
            titleText.contentWidth > titleContainer.width

        property real scrollGap: 80
        property real scrollOffset: 0

        // Scroll tuning
        property real scrollMsPerPixel: 16
        property real slowdownDistance: 32

        property real totalScrollDistance:
            titleText.width + scrollGap

        // Normal centered title when it fits
        Text {
            id: centeredTitle

            anchors.centerIn: parent

            visible: !titleContainer.needsScroll

            text: mediaService.title.length > 0
                ? mediaService.title
                : "No Media Playing"

            color: "white"

            font.pixelSize: 30
            font.bold: true
        }

        // Moving content for long titles
        Item {
            id: marqueeContent

            visible: titleContainer.needsScroll

            x: -titleContainer.scrollOffset
            height: parent.height

            Text {
                id: titleText

                anchors.verticalCenter: parent.verticalCenter

                text: mediaService.title

                color: "white"

                font.pixelSize: 30
                font.bold: true
            }

            Text {
                id: titleTextCopy

                anchors.left: titleText.right
                anchors.leftMargin: titleContainer.scrollGap
                anchors.verticalCenter: parent.verticalCenter

                text: titleText.text

                color: titleText.color

                font.pixelSize: titleText.font.pixelSize
                font.bold: titleText.font.bold
            }
        }

        SequentialAnimation {
            id: marqueeAnimation

            loops: Animation.Infinite
            running: titleContainer.needsScroll

            // Pause at the normal starting position
            PauseAnimation {
                duration: 3000
            }

            // Constant-speed portion
            NumberAnimation {
                target: titleContainer
                property: "scrollOffset"

                from: 0

                to:
                    titleContainer.totalScrollDistance
                    - titleContainer.slowdownDistance

                duration:
                    (
                        titleContainer.totalScrollDistance
                        - titleContainer.slowdownDistance
                    )
                    * titleContainer.scrollMsPerPixel

                easing.type: Easing.Linear
            }

            // Final short slowdown
            NumberAnimation {
                target: titleContainer
                property: "scrollOffset"

                to: titleContainer.totalScrollDistance

                duration:
                    titleContainer.slowdownDistance
                    * titleContainer.scrollMsPerPixel
                    * 2

                easing.type: Easing.OutQuad
            }

            // Invisible reset because the second copy is now
            // in exactly the same position as the first copy was
            ScriptAction {
                script: titleContainer.scrollOffset = 0
            }
        }
    }

    // --------------------------------------------------
    // Artist
    // --------------------------------------------------

    Text {
        id: artistText

        anchors.top: titleContainer.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width - 80

        text: mediaService.artist

        color: "#b9bec8"

        font.pixelSize: 20

        horizontalAlignment: Text.AlignHCenter

        elide: Text.ElideRight
        maximumLineCount: 1
    }

    // --------------------------------------------------
    // Progress slider
    // --------------------------------------------------

    Slider {
        id: progressSlider

        width: 350
        height: 28

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: artistText.bottom
        anchors.topMargin: 25

        from: 0
        to: root.durationValue
        value: root.progressValue

        // Background track
        background: Rectangle {
            x: progressSlider.leftPadding
            y: progressSlider.topPadding +
            progressSlider.availableHeight / 2 - height / 2

            width: progressSlider.availableWidth
            height: 8
            radius: 4

            color: "#555B64"

            // Filled portion
            Rectangle {
                width: progressSlider.visualPosition * parent.width
                height: parent.height
                radius: parent.radius

                color: "white"
            }
        }

        // Invisible handle
        handle: Item {
            width: 0
            height: 0
        }

        onMoved: {
            if (mediaService.seekEnabled) {
                root.progressValue = value
            }
        }

        onPressedChanged: {
            if (!pressed && mediaService.seekEnabled) {
                mediaService.seekTo(value)
            }
        }

        // Block interaction when seeking isn't available
        MouseArea {
            anchors.fill: parent
            enabled: !mediaService.seekEnabled
            acceptedButtons: Qt.AllButtons
        }
    }

    // --------------------------------------------------
    // Elapsed / remaining time
    // --------------------------------------------------

    Row {
        id: timeRow

        width: progressSlider.width

        anchors.top: progressSlider.bottom
        anchors.topMargin: -4
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            width: parent.width / 2

            text: mediaService.duration > 0
                ? root.formatTime(Math.floor(root.progressValue))
                : ""

            color: "#b9bec8"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            width: parent.width / 2

            text: mediaService.duration > 0
                ? "-" + root.formatTime(
                        Math.max(
                            0,
                            Math.ceil(
                                root.durationValue - root.progressValue
                            )
                        )
                    )
                : ""

            color: "#b9bec8"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignRight
        }
    }

    // --------------------------------------------------
    // Playback controls
    // --------------------------------------------------

    Row {
        id: controlsRow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: timeRow.bottom
        anchors.topMargin: 20

        spacing: 60

        // Previous
        IconButton {
            width: 72
            height: 72

            iconSize: 52

            source:
                "../assets/icons/media/player-track-prev.svg"

            onClicked: {
                mediaService.previous()
            }
        }

        // Play / Pause
        IconButton {
            width: 88
            height: 88

            iconSize: 62
            iconYOffset: -5

            source:
                mediaService.isPlaying
                ? "../assets/icons/media/player-pause.svg"
                : "../assets/icons/media/player-play.svg"

            onClicked: {
                mediaService.toggle_play_pause()
            }
        }

        // Next
        IconButton {
            width: 72
            height: 72

            iconSize: 52

            source:
                "../assets/icons/media/player-track-next.svg"

            onClicked: {
                mediaService.next()
            }
        }
    }
}