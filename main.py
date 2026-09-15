import sys
import asyncio
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from qasync import QEventLoop

from services.media_service import MediaService


def main():
    app = QGuiApplication(sys.argv)

    loop = QEventLoop(app)
    asyncio.set_event_loop(loop)

    engine = QQmlApplicationEngine()

    media_service = MediaService()

    # Make mediaService available inside QML
    engine.rootContext().setContextProperty(
        "mediaService",
        media_service
    )

    qml_file = Path(__file__).resolve().parent / "Main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    app.aboutToQuit.connect(loop.stop)

    with loop:
        loop.run_until_complete(media_service.initialize())
        loop.run_forever()


if __name__ == "__main__":
    main()