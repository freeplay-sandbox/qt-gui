import QtQuick 2.0
import Ros 1.0

Item {
    id: staticImage
    property double scale: 1.0
    width: 2*parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    height: width
    x: -100
    y: -100
    visible: false
    rotation: 0

    property string name: ""
    property string image: "res/"+name+".png"
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
        var good = false
        while(!good){
            good = true
            x = drawingarea.width * (.15 + 0.7 * Math.random())
            y = drawingarea.height * (.15 + 0.7 * Math.random())
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<20000 && list[i].name !== name){
                    good = false
                }
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
                console.log(list[i].name)
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<20000 && list[i].name !== name){
                    good = false
                }
            }
        }
        visible = true
    }
}
