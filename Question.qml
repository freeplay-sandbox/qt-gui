import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

Item {
    property string text: ""
    property string mainImageName: ""
    property string image1Name: ""
    property string image2Name: ""
    property string image3Name: ""
    property string image4Name: ""
    property string nextState: ""
    id: question
    anchors.fill:parent
    Rectangle{
        anchors.fill:parent
        color: "white"
    }
    ColumnLayout{
        anchors.fill:parent
        spacing: height/20

        Image {
            id: mainImage
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            width: 8 * scale * question.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
            source: "res/" + question.mainImageName + ".png"
        }

        Label {
            id: questionText
            anchors.horizontalCenter: parent.horizontalCenter
            text: question.text
            font.pixelSize: 40
            color: "black"
        }
        RowLayout{
            spacing: question.width/10
            anchors.horizontalCenter: parent.horizontalCenter
            width: question.width
            height: question.height / 3
            property double maximumWidth: width/6

            Image {
                id: image1
                source: "res/" + question.image1Name + ".png"
                property bool selected: false
                fillMode: Image.PreserveAspectFit
                Layout.maximumWidth: parent.maximumWidth
                Layout.maximumHeight: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        image1.selected = !image1.selected
                    }
                }
                Rectangle {
                    width: parent.width+10
                    height: parent.height+10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"
                    border.color: "green"
                    border.width: 3
                    visible: image1.selected
                }
            }
            Image {
                id: image2
                source: "res/" + question.image2Name + ".png"
                property bool selected: false
                fillMode: Image.PreserveAspectFit
                Layout.maximumWidth: parent.maximumWidth
                Layout.maximumHeight: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        image2.selected = !image2.selected
                    }
                }
                Rectangle {
                    width: parent.width+10
                    height: parent.height+10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"
                    border.color: "green"
                    border.width: 3
                    visible: image2.selected
                }
            }
            Image {
                id: image3
                source: "res/" + question.image3Name + ".png"
                property bool selected: false
                fillMode: Image.PreserveAspectFit
                Layout.maximumWidth: parent.maximumWidth
                Layout.maximumHeight: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        image3.selected = !image3.selected
                    }
                }
                Rectangle {
                    width: parent.width+10
                    height: parent.height+10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"
                    border.color: "green"
                    border.width: 3
                    visible: image3.selected
                }
            }
            Image {
                id: image4
                source: "res/" + question.image4Name + ".png"
                property bool selected: false
                fillMode: Image.PreserveAspectFit
                Layout.maximumWidth: parent.maximumWidth
                Layout.maximumHeight: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        image4.selected = !image4.selected
                    }
                }
                Rectangle {
                    width: parent.width+10
                    height: parent.height+10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"
                    border.color: "green"
                    border.width: 3
                    visible: image4.selected
                }
            }
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 90
            height: 30
            id: confirm
            text: "Confirm"
            style: ButtonStyle {
                label: Text {
                    font.family: "Helvetica"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 30
                    text: confirm.text
                }
            }
            onClicked: {
                globalStates.state = nextState
                var log=[mainImageName,image1Name,image1.selected,image2Name,image2.selected,image3Name,image3.selected,image4Name,image4.selected]
                fileio.write(window.qlogfilename, log.join(","));
                image1.selected = false
                image2.selected = false
                image3.selected = false
                image4.selected = false
            }
        }
    }
}
