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

        width: 2560
        height: 720

        scale:
            physicalPreview
            ? window.width / 2560
            : 1.0

        transformOrigin: Item.TopLeft

        Row {
            anchors.fill: parent

            DiscordPanel {
                width: 320
                height: parent.height
            }

            StatsPanel {
                width: 1140
                height: parent.height
            }

            ClockPanel {
                width: 600
                height: parent.height
            }

            MediaPanel {
                width: 500
                height: parent.height
            }
        }
    }
}