import QtQuick 2.2
import QtQuick.Window 2.2

import Box2D 2.0

import "zoo.js" as ZooScripts

Window {

    id: zoo
    visible: true
    visibility: Window.FullScreen
    width: Screen.width
    height: Screen.height
    color: "#000000"
    title: qsTr("Zoo Builder")

    property double physicalMapLength: 412 //mm
    property double physicalCubeSize: 30 //mm

    property int nbCubes: 40

    Image {
            id: map
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: "res/map.svg"
    }


    property Body pressedBody: null

    MouseJoint {
            id: mouseJoint
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
                    x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                    y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
            }

    }

    Character {
        image: "res/sprite-zebra.png"
    }
    Character {
        scale: 1.5
        image: "res/sprite-elephant.png"
    }
     Character {
        scale: 1.5
        bbScale: 0.5
        image: "res/sprite-giraffe.png"
    }
   Character {
        scale: 1.5
        image: "res/sprite-hippo.png"
    }
    Character {
        image: "res/sprite-lion.png"
    }
    Character {
        image: "res/sprite-crocodile.png"
    }
     Character {
        scale: 1.5
        bbScale: 0.8
        image: "res/sprite-rhino.png"
    }
   Character {
        bbScale: 0.8
        image: "res/sprite-leopard.png"
    }


       Rectangle {
           id: debugButton
           x: 50
           y: 50
           width: 120
           height: 30
           Text {
               text: debugDraw.visible ? "Debug view: on" : "Debug view: off"
               anchors.centerIn: parent
           }
           color: "#DEDEDE"
           border.color: "#999"
           radius: 5
           MouseArea {
               anchors.fill: parent
               onClicked: debugDraw.visible = !debugDraw.visible;
           }
       }

        DebugDraw {
            id: debugDraw
            world: physicsWorld
            opacity: 0.75
            visible: false
        }
}
