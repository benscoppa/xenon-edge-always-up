import QtQuick


Rectangle {
    id: root

    color: "#111318"

    property date currentTime: new Date()

    FontLoader {
        id: bundledClockFont
        source: "../assets/fonts/default/bruno_ace_sc/BrunoAceSC-Regular.ttf"
    }

    FontLoader {
        id: localClockFontNumber
        source: "../assets/fonts/local/local-number-font.ttf"
    }

    FontLoader {
        id: localClockFontText
        source: "../assets/fonts/local/local-text-font.ttf"
    }

    property bool useLocalFontNumber: true
    property bool useLocalFontText: false

    property string numberFontFamily:
        useLocalFontNumber && localClockFontNumber.status === FontLoader.Ready
        ? localClockFontNumber.name
        : bundledClockFont.name

    property string textFontFamily:
        useLocalFontText && localClockFontText.status === FontLoader.Ready
        ? localClockFontText.name
        : bundledClockFont.name

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = new Date()
        }
    }

    function format12Hour(date) {
        var hours = date.getHours()
        var minutes = date.getMinutes()

        hours = hours % 12

        if (hours === 0)
            hours = 12

        var minuteText = minutes < 10
            ? "0" + minutes
            : minutes

        return hours + ":" + minuteText
    }

    Column {
        anchors.centerIn: parent
        spacing: 12

        // Main time
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: format12Hour(root.currentTime)
            color: "white"

            font.family: root.numberFontFamily
            font.pixelSize: 150
            font.bold: true
        }

        // AM / PM
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatTime(root.currentTime, "AP").toUpperCase()
            color: "#9da3ad"

            font.family: root.textFontFamily
            font.pixelSize: 45
        }

        // Day
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(root.currentTime, "dddd").toUpperCase()
            color: "white"

            font.family: root.textFontFamily
            font.pixelSize: 60
            font.bold: true
        }

        // Date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(root.currentTime, "MMMM d, yyyy").toUpperCase()
            color: "#9da3ad"

            font.family: root.textFontFamily
            font.pixelSize: 30
        }
    }
}