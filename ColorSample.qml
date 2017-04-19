import QtQuick 2.0

Rectangle {

    id: colorsampler

    width: 50
    height: width

    property bool selected: false

    signal tapped(var myself)

    border.width: selected ? 10 : 0
    border.color: Qt.darker(color)

    color: "grey"

    MouseArea {
        anchors.fill: parent
        onClicked: tapped(colorsampler)
    }

    Rectangle {
        id: dot
        width: parent.width/2
        visible: parent.selected?true:false
        height: width
        radius: width/2
        color: Qt.darker(parent.color)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}
