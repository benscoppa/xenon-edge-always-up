import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root

    color: "#111318"

    property string channelName: "Gaming"

    property var users: [
        {
            name: "Ben",
            speaking: true,
            muted: false
        },
        {
            name: "Alex",
            speaking: false,
            muted: false
        },
        {
            name: "Chris",
            speaking: false,
            muted: true
        }
    ]

    Column {
        anchors.fill: parent
        anchors.margins: 20

        spacing: 18

        Text {
            text: "DISCORD"

            color: "#8D94A0"

            font.pixelSize: 18
            font.bold: true
        }

        Text {
            text: root.channelName

            color: "white"

            font.pixelSize: 28
            font.bold: true

            width: parent.width
            elide: Text.ElideRight
        }

        Rectangle {
            width: parent.width
            height: 1

            color: "#2A2E35"
        }

        ListView {
            width: parent.width
            height: parent.height - 115

            model: root.users

            spacing: 12
            clip: true

            delegate: Item {
                width: ListView.view.width
                height: 72

                Row {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 14

                    // Avatar / speaking ring
                    Rectangle {
                        width: 60
                        height: 60

                        radius: width / 2

                        color: "transparent"

                        border.width: modelData.speaking ? 3 : 0
                        border.color: "#76E09A"

                        Item {
                            id: avatarImageContainer

                            anchors.centerIn: parent

                            width: 52
                            height: 52

                            // Fallback background
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "#2B3038"
                            }

                            // Discord avatar
                            Image {
                                id: avatarImage

                                anchors.fill: parent

                                source: modelData.avatarUrl

                                fillMode: Image.PreserveAspectCrop
                                smooth: true

                                visible: false
                            }

                            // Circular mask
                            Rectangle {
                                id: avatarMask

                                anchors.fill: parent

                                radius: width / 2
                                color: "white"

                                visible: false
                            }

                            MultiEffect {
                                anchors.fill: parent

                                source: avatarImage

                                maskEnabled: true
                                maskSource: avatarMask

                                visible: avatarImage.status === Image.Ready
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter

                        width:
                            parent.width - 74

                        spacing: 4

                        Text {
                            text: modelData.name

                            color:
                                modelData.muted
                                ? "#777D87"
                                : "white"

                            font.pixelSize: 22
                            font.bold: true

                            width: parent.width
                            elide: Text.ElideRight
                        }

                        Text {
                            text:
                                modelData.speaking
                                ? "Speaking"
                                : modelData.muted
                                    ? "Muted"
                                    : ""

                            color:
                                modelData.speaking
                                ? "#76E09A"
                                : "#777D87"

                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }
}