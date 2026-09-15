import QtQuick
import QtQuick.Window

Window {
    width: 2560
    height: 720

    minimumWidth: 2560
    minimumHeight: 720
    maximumWidth: 2560
    maximumHeight: 720

    visible: true
    title: "XENEON Edge Preview"

    color: "#101014"

    Rectangle {
        anchors.fill: parent
        color: "#101014"

        Text {
            anchors.centerIn: parent

            text: "2560 × 720\nXENEON EDGE PREVIEW"
            color: "white"

            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: 48
            font.bold: true
        }
    }
}