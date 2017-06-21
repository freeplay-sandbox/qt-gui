import QtQuick 2.0
import Ros 1.0

Item {
    id: staticImage
    property double scale: 1.0
    width: 2*parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    height: width
    x: 0
    y: 0
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
        x = drawingarea.width * (.15 + 0.7 * Math.random())
        y = drawingarea.height * (.15 + 0.7 * Math.random())
    }
}
