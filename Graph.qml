import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

Item {
    property string text: ""
    property var imageNames: ['flower', 'dragonfly', 'bird', 'wolf', 'butterfly', 'corn', 'apple', 'rat', 'grasshopper', 'eagle', 'fly', 'frog', 'python']
    property string nextState: "tutorialIntro"
    id: graph
    anchors.fill:parent
    visible: false
    Rectangle{
        id: background
        property string name: "background"
        anchors.fill:parent
        color: "white"
    }

    Item {
        id:images
    }

    Item {
        id:arrows
        visible: true
        anchors.fill:parent
    }

    MouseArea {
        anchors.fill: parent
        property bool moving: false
        property var lastArrow: null

        onPressed: {
            var obj = images.childAt(mouseX, mouseY)
            if (obj !== null){
                var component = Qt.createComponent("Arrow.qml")
                lastArrow = component.createObject(arrows,{"origin":obj, "end":Qt.point(mouseX,mouseY)})
                moving = true
            }
        }
        onPositionChanged: {
            if(moving){
                lastArrow.end = Qt.point(mouseX, mouseY)
                lastArrow.paint()
            }
        }
        onReleased: {
            if(moving){
                moving = false
                var obj = images.childAt(mouseX, mouseY)
                if (obj !== null && obj.name !== lastArrow.origin.name){
                    lastArrow.end=obj
                    lastArrow.paint()
                }
                else{
                    lastArrow.destroy()
                }
            }
        }
    }

    Rectangle{
        id: undoButton
        anchors.left: parent.left
        anchors.leftMargin: parent.width/20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.width/20
        width: parent.width/15
        height: width
        radius: width/2
        color: "red"
        border.color: "black"
        border.width: width / 10
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 15
            font.bold: true
            text: "Undo"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(arrows.children.length>0)
                    arrows.children[arrows.children.length-1].destroy()
            }
        }
    }
    Rectangle{
        id: continueButton
        anchors.right: parent.right
        anchors.rightMargin: parent.width/20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.width/20
        width: parent.width/15
        height: width
        radius: width/2
        color: "green"
        border.color: "black"
        border.width: width / 10
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "Continue"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                stop()
            }
        }
    }
    function prepare() {
        for(var i=images.children.length-1;i>=0;i--)
            images.children[i].destroy()
         var offset = 250
         var radiusHeight=(graph.height-offset)/2
         var radiusWidth=(graph.width-offset)/2
         for(var i=0; i<imageNames.length;i++){
             var string = "import QtQuick 2.0; Image{property string name: \""+imageNames[i]+"\"}"
 //+ ";width:100;image:/res/"+imageNames[i]+".png ; x:"+radius*Math.cos(2*Math.PI*i/imageNames.length)+parent.width/2 +"; y: "+radius*Math.sin(2*Math.PI*i/imageNames.length)+parent.height/2+"
             var obj = Qt.createQmlObject(string, images)
             obj.height = offset-50
             obj.fillMode = Image.PreserveAspectFit
             obj.source = "/res/"+imageNames[i]+".png"
             obj.x = radiusWidth*Math.cos(2*Math.PI*i/imageNames.length)+graph.width/2-offset/4
             obj.y = radiusHeight*Math.sin(2*Math.PI*i/imageNames.length)+graph.height/2-offset/2
         }
    }

    function start() {
        graph.visible = true
        }

    function stop() {
        globalStates.state = nextState
        graph.visible = false
        fileio.write(window.qlogfilename,"test")
        //Could potentially log time too
        for(var i=arrows.children.length-1;i>=0;i--){
            var log=[arrows.children[i].origin.name, arrows.children[i].end.name]
            arrows.children[i].destroy()
            fileio.write(window.qlogfilename, log.join(","));
        }
    }

/*
    Arrow {
        id: arrow
        origin: ima
        end: im1

    }



/*
        Label {
            id: graphText
            anchors.horizontalCenter: parent.horizontalCenter
            text: graph.text
            font.pixelSize: 40
            color: "black"
        }
        RowLayout{
            spacing: graph.width/10
            anchors.horizontalCenter: parent.horizontalCenter
            width: graph.width
            height: graph.height / 3
            property double maximumWidth: width/6

            Image {
                id: image1
                source: "res/" + graph.image1Name + ".png"
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
                source: "res/" + graph.image2Name + ".png"
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
                source: "res/" + graph.image3Name + ".png"
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
                source: "res/" + graph.image4Name + ".png"
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
    */
}
