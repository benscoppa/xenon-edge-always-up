import QtQuick

Item {
    id: root

    property url source
    property int iconSize: 48

    property real iconXOffset: 0
    property real iconYOffset: 0

    signal clicked()

    width: 70
    height: 70

    Image {
        anchors.centerIn: parent

        anchors.horizontalCenterOffset: root.iconXOffset
        anchors.verticalCenterOffset: root.iconYOffset

        width: root.iconSize
        height: root.iconSize

        source: root.source
        fillMode: Image.PreserveAspectFit

        sourceSize.width: root.iconSize * 4
        sourceSize.height: root.iconSize * 4

        smooth: true
        mipmap: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}