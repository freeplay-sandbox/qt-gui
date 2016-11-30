import QtQuick 2.2
import QtQuick.Window 2.2

import Box2D 2.0

import Ros 1.0

Window {

    id: zoo
    visible: true
    //visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:800
    height: 600
    color: "#000000"
    title: qsTr("Zoo Builder")

    property double physicalMapWidth: 412 //mm
    property double physicalCubeSize: 30 //mm
    property double pixel2meter: (physicalMapWidth / 1000) / map.paintedHeight

    property int nbCubes: 0

    Image {
        id: map
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        source: "res/map.svg"

        Item {
            // this item sticks to the 'visual' origin of the map, taking into account
            // possible margins appearing when resizing
            id: mapOrigin
            rotation: map.rotation
            x: map.x + (map.width - map.paintedWidth)/2
            y: map.y + (map.height - map.paintedHeight)/2
        }
    }


    property Body pressedBody: null

    MouseJoint {
            id: mouseJoint
            bodyA: anchor
            dampingRatio: 1
            maxForce: 1
    }

    MouseJoint {
            id: externalJoint
            bodyA: anchor
            dampingRatio: 1
            maxForce: 1
    }

    MouseArea {
            id: mouseArea
            anchors.fill: parent

            onPressed: {
                    if (pressedBody != null) {
                            mouseJoint.maxForce = pressedBody.getMass() * 500;
                            mouseJoint.target = Qt.point(mouseX, mouseY);
                            mouseJoint.bodyB = pressedBody;
                    }
            }

            onPositionChanged: {
                    mouseJoint.target = Qt.point(mouseX, mouseY);
            }

            onReleased: {
                    mouseJoint.bodyB = null;
                    pressedBody = null;
            }
    }

    RosPositionController {
        id: roscontrol

        Rectangle {
            x: parent.x
            y: parent.y
            width: 10
            height: 10
            color: "red"
        }

        property var target: null
        origin: mapOrigin
        pixelscale: zoo.pixel2meter

        onPositionChanged: {
            console.log("Received pose update! x: " + x + ", y: " + y);
            if (target === null) {
                var obj = map.childAt(x, y);
                if (obj === null) return;

                target = obj.body

                externalJoint.maxForce = target.getMass() * 500;
                externalJoint.bodyB = target;

            }
            externalJoint.target = Qt.point(parent.x, parent.y);
        }

//        onReleasedChanged: {
//            externalJoint.bodyB = null;
//        }

    }

    World {
            id: physicsWorld
            gravity: Qt.point(0.0, 0.0);

    }

    RectangleBoxBody {
            id: rightwall
            color: "#000000FF"
            width: 20
            anchors {
                    right: parent.right
                    bottom: parent.bottom
                    top: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
    }
    RectangleBoxBody {
            id: leftwall
            color: "#000000FF"
            width: 20
            anchors {
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
    }
    RectangleBoxBody {
            id: top
            color: "#000000FF"
            height: 20
            anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
            }
            world: physicsWorld
            friction: 1
            density: 1
    }
    RectangleBoxBody {
            id: ground
            color: "#000000FF"
            height: 20
            anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
            }
            world: physicsWorld
            friction: 1
            density: 1
    }

    Body {
            id: anchor
            world: physicsWorld
    }

    Repeater {
            model: nbCubes
            Cube {
                    name: "cube_" + index
                    x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                    y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
            }

    }

    Character {
        name: "zebra"
        image: "res/sprite-zebra.png"
    }
    Character {
        name: "elephant"
        scale: 1.5
        image: "res/sprite-elephant.png"
    }
     Character {
        name: "giraffe"
        scale: 1.5
        bbScale: 0.5
        image: "res/sprite-giraffe.png"
    }
   Character {
        name: "hippo"
        scale: 1.5
        image: "res/sprite-hippo.png"
    }
    Character {
        name: "lion"
        image: "res/sprite-lion.png"
    }
    Character {
        name: "crocodile"
        image: "res/sprite-crocodile.png"
    }
     Character {
        name: "rhino"
        scale: 1.5
        bbScale: 0.8
        image: "res/sprite-rhino.png"
    }
   Character {
        name: "leopard"
        bbScale: 0.8
        image: "res/sprite-leopard.png"
    }


//       Rectangle {
//           id: debugButton
//           x: 50
//           y: 50
//           width: 120
//           height: 30
//           Text {
//               text: debugDraw.visible ? "Debug view: on" : "Debug view: off"
//               anchors.centerIn: parent
//           }
//           color: "#DEDEDE"
//           border.color: "#999"
//           radius: 5
//           MouseArea {
//               anchors.fill: parent
//               onClicked: debugDraw.visible = !debugDraw.visible;
//           }
//       }

//        DebugDraw {
//            id: debugDraw
//            world: physicsWorld
//            opacity: 0.75
//            visible: false
//        }
}
