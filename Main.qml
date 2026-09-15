import QtQuick
import QtQuick.Window
import "components"

Window {
    id: window

    property bool physicalPreview: false

    visible: true
    title: "XENEON Edge Preview"
    color: "black"

    width: physicalPreview ? 1518 : 2560
    height: physicalPreview ? 427 : 720

    minimumWidth: width
    minimumHeight: height
    maximumWidth: width
    maximumHeight: height

    Item {
        id: edgeCanvas

        // Always design at the real XENEON Edge resolution
        width: 2560
        height: 720

        scale: physicalPreview ? window.width / 2560 : 1.0
        transformOrigin: Item.TopLeft

        Row {
            anchors.fill: parent

            DiscordPanel {
                width: 220
                height: parent.height
            }

            StatsPanel {
                width: 1000
                height: parent.height
            }

            ClockPanel {
                width: 640
                height: parent.height
            }

            MediaPanel {
                width: 700
                height: parent.height
            }
        }
    }
}