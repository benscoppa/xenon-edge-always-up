import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    color: "#20242c"

    property bool isPlaying: false
    property string trackTitle: "Example Song"
    property string artistName: "Example Artist"
    property real progressValue: 72
    property real durationValue: 245

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)

        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    // Background / theme layer
    Rectangle {
        anchors.fill: parent
        color: "#20242c"
    }

    // Album art placeholder
    Rectangle {
        id: albumArt

        width: 300
        height: 300

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 80

        radius: 12
        color: "#414650"

        Text {
            anchors.centerIn: parent
            text: "ALBUM ART"
            color: "white"
            font.pixelSize: 28
        }
    }

    // Track title
    Text {
        id: titleText

        anchors.top: albumArt.bottom
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter

        text: root.trackTitle
        color: "white"

        font.pixelSize: 30
        font.bold: true
    }

    // Artist
    Text {
        id: artistText

        anchors.top: titleText.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        text: root.artistName
        color: "#b9bec8"

        font.pixelSize: 20
    }

    // Progress bar
    Slider {
        id: progressSlider

        width: parent.width - 300

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: artistText.bottom
        anchors.topMargin: 25

        from: 0
        to: root.durationValue
        value: root.progressValue

        onMoved: {
            root.progressValue = value
        }
    }

    // Time labels
    Row {
        id: timeRow

        width: progressSlider.width

        anchors.top: progressSlider.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            width: parent.width / 2

            text: root.formatTime(root.progressValue)

            color: "#b9bec8"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            width: parent.width / 2

            text: "-" + root.formatTime(
                      Math.max(0, root.durationValue - root.progressValue)
                  )

            color: "#b9bec8"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignRight
        }
    }

    // Controls
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

            source: "../assets/icons/media/player-track-prev.svg"

            onClicked: {
                console.log("Previous")
            }
        }

        // Play / Pause
        IconButton {
            width: 88
            height: 88
            iconSize: 62
            iconYOffset: -5

            source: root.isPlaying
                ? "../assets/icons/media/player-pause.svg"
                : "../assets/icons/media/player-play.svg"

            onClicked: {
                root.isPlaying = !root.isPlaying
            }
        }

        // Next
        IconButton {
            width: 72
            height: 72
            iconSize: 52

            source: "../assets/icons/media/player-track-next.svg"

            onClicked: {
                console.log("Next")
            }
        }
    }

    // Fake playback timer
    Timer {
        interval: 1000
        running: root.isPlaying
        repeat: true

        onTriggered: {
            if (root.progressValue < root.durationValue) {
                root.progressValue += 1
            }
        }
    }
}