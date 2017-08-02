import QtQuick 2.0
import Ros 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: staticImage
    property double scale: initialScale
    property double initialScale: 1
    width: 2 * scale * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    height: width
    x: -100
    y: -100
    visible: false
    rotation: 0
    property double initialLife: .25
    property double life: initialLife
    property double lifeChange: 0

    property string name: ""
    property string type: ""
    property string image: "res/"+type+".png"
    property int epsilon: 20

    Image {
        id: image
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        source: parent.image

        Item {
            // this item sticks to the 'visual' origin of the object, taking into account
            // possible margins appearing when resizing
            id: imageOrigin
            rotation: parent.rotation
            x: parent.x + (parent.width - parent.paintedWidth)/2
            y: parent.y + (parent.height - parent.paintedHeight)/2
        }
    }

    NumberAnimation {id: death; target: staticImage; property: "scale"; from: scale; to: 0.1; duration: 1000}
    //NumberAnimation {id: lifeChangeAnimation; target: staticImage; property: "life"; from: life; to: life+lifeChange; duration: 800}

    onScaleChanged: {
        if(scale <= 0.1 && visible){
            x=-100
            y=-100
            visible = false
            scale = initialScale
            itemDying(name)
        }
    }

    Item {
        id: objectCenter
        anchors.centerIn: parent
        rotation: parent.rotation
        TFBroadcaster {
            target: parent
            frame: parent.parent.name

            origin: mapOrigin
            parentframe: mapOrigin.name

            pixelscale: sandbox.pixel2meter
        }
    }

    function relocate(){
        var counter = 0
        var good=false
        while(!good){
            good=true
            x = drawingarea.width * (.1 + 0.8 * Math.random())
            y = drawingarea.height * (.1 + 0.8 * Math.random())
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<60000 && list[i].name !== name){
                    good = false
                }
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<60000 && list[i].type !== type){
                    good = false
                }
            }
        }
        visible = true
    }

    function locateCloseTo(item){
        var angle = Math.PI/2 * (Math.random() - 0.5)
        x=item.x+40*Math.cos(angle)
        y=item.y+40*Math.sin(angle)
        visible = true
    }

    function changeLife(value){
        life+=value
        //lifeChange = value
        //lifeChangeAnimation.start()
        /*
        lifeChangeAnimation.start()
        if(value<0)
        {
            lifeSlider.blinkColor = "red"
        }
        else{
            lifeSlider.blinkColor = "green"
        }
        lifeSlider.animation.start()*/
    }

    function initiate(){
        scale = initialScale
        life = initialLife
    }

    onNameChanged: type = name.split("-")[0]
    onLifeChanged: if(life<=0) death.start()
}
