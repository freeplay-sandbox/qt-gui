import QtQuick 2.7
import QtQuick.Window 2.2

import "zoo.js" as ZooScripts

Window {

    id: zoo
    visible: true
    width: 640
    height: 480
    title: qsTr("Zoo Builder")

    property int nbCubes: 10

    Component.onCompleted: ZooScripts.createCubes();

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log(qsTr('Clicked on background. Text: "' + textEdit.text + '"'))
        }

        Image {
            id: map
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            source: "res/map.svg"
        }


    }

}
