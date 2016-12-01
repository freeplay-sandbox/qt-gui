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
                anchors.centerIn: parent
                width: 30
                height: width
                radius: width/2
                border.color: "#FF330022"
                color: "#00000000"
                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: width
                    radius: width/2
                    color: parent.border.color
                }
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
        id: zebra
        name: "zebra"
        image: "res/sprite-zebra.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(zebra.origin.x + 0,                 zebra.origin.y + 60*zebra.bbratio),
                Qt.point(zebra.origin.x + 100*zebra.bbratio, zebra.origin.y + 0),
                Qt.point(zebra.origin.x + 180*zebra.bbratio, zebra.origin.y + 100*zebra.bbratio),
                Qt.point(zebra.origin.x + 260*zebra.bbratio, zebra.origin.y + 150*zebra.bbratio),
                Qt.point(zebra.origin.x + 235*zebra.bbratio, zebra.origin.y + 280*zebra.bbratio),
                Qt.point(zebra.origin.x + 100*zebra.bbratio, zebra.origin.y + 280*zebra.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: elephant
        name: "elephant"
        scale: 1.5
        image: "res/sprite-elephant.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(elephant.origin.x +  23*elephant.bbratio, elephant.origin.y + 24*elephant.bbratio),
                Qt.point(elephant.origin.x + 216*elephant.bbratio, elephant.origin.y + 0),
                Qt.point(elephant.origin.x + 300*elephant.bbratio, elephant.origin.y + 90*elephant.bbratio),
                Qt.point(elephant.origin.x + 270*elephant.bbratio, elephant.origin.y + 200*elephant.bbratio),
                Qt.point(elephant.origin.x + 135*elephant.bbratio, elephant.origin.y + 200*elephant.bbratio),
                Qt.point(elephant.origin.x + 0,                    elephant.origin.y + 107*elephant.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: giraffe
        name: "giraffe"
        scale: 1.5
        image: "res/sprite-giraffe.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(giraffe.origin.x + 88*giraffe.bbratio, giraffe.origin.y + 0),
                Qt.point(giraffe.origin.x + 200*giraffe.bbratio, giraffe.origin.y + 190*giraffe.bbratio),
                Qt.point(giraffe.origin.x + 188*giraffe.bbratio, giraffe.origin.y + 324*giraffe.bbratio),
                Qt.point(giraffe.origin.x + 85*giraffe.bbratio, giraffe.origin.y + 321*giraffe.bbratio),
                Qt.point(giraffe.origin.x + 0,                    giraffe.origin.y + 55*giraffe.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: hippo
        name: "hippo"
        scale: 1.5
        image: "res/sprite-hippo.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(hippo.origin.x + 133*hippo.bbratio, hippo.origin.y + 0),
                Qt.point(hippo.origin.x + 321*hippo.bbratio, hippo.origin.y + 71*hippo.bbratio),
                Qt.point(hippo.origin.x + 305*hippo.bbratio, hippo.origin.y + 200*hippo.bbratio),
                Qt.point(hippo.origin.x + 133*hippo.bbratio, hippo.origin.y + 200*hippo.bbratio),
                Qt.point(hippo.origin.x + 37*hippo.bbratio, hippo.origin.y + 138*hippo.bbratio),
                Qt.point(hippo.origin.x + 0,                 hippo.origin.y + 40*hippo.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: lion
        name: "lion"
        image: "res/sprite-lion.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(lion.origin.x + 90*lion.bbratio, lion.origin.y + 0),
                Qt.point(lion.origin.x + 184*lion.bbratio, lion.origin.y + 47*lion.bbratio),
                Qt.point(lion.origin.x + 224*lion.bbratio, lion.origin.y + 161*lion.bbratio),
                Qt.point(lion.origin.x + 133*lion.bbratio, lion.origin.y + 263*lion.bbratio),
                Qt.point(lion.origin.x + 38*lion.bbratio, lion.origin.y + 240*lion.bbratio),
                Qt.point(lion.origin.x + 0,                 lion.origin.y + 87*lion.bbratio),
                Qt.point(lion.origin.x + 23*lion.bbratio, lion.origin.y + 27*lion.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: crocodile
        name: "crocodile"
        image: "res/sprite-crocodile.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(crocodile.origin.x + 76*crocodile.bbratio, crocodile.origin.y + 37*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 127*crocodile.bbratio, crocodile.origin.y + 7*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 213*crocodile.bbratio, crocodile.origin.y + 5*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 221*crocodile.bbratio, crocodile.origin.y + 221*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 43*crocodile.bbratio, crocodile.origin.y + 241*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 0,                 crocodile.origin.y + 213*crocodile.bbratio),
                Qt.point(crocodile.origin.x + 5*crocodile.bbratio, crocodile.origin.y + 185*crocodile.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: rhino
        name: "rhino"
        scale: 1.5
        image: "res/sprite-rhino.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(rhino.origin.x + 112*rhino.bbratio, rhino.origin.y + 15*rhino.bbratio),
                Qt.point(rhino.origin.x + 270*rhino.bbratio, rhino.origin.y + 70*rhino.bbratio),
                Qt.point(rhino.origin.x + 306*rhino.bbratio, rhino.origin.y + 109*rhino.bbratio),
                Qt.point(rhino.origin.x + 296*rhino.bbratio, rhino.origin.y + 229*rhino.bbratio),
                Qt.point(rhino.origin.x + 129*rhino.bbratio, rhino.origin.y + 230*rhino.bbratio),
                Qt.point(rhino.origin.x + 10*rhino.bbratio, rhino.origin.y + 144*rhino.bbratio),
                Qt.point(rhino.origin.x + 8*rhino.bbratio, rhino.origin.y + 51*rhino.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
    }
    Character {
        id: leopard
        name: "leopard"
        image: "res/sprite-leopard.png"
        boundingbox: Polygon {
            vertices: [
                Qt.point(leopard.origin.x, leopard.origin.y),
                Qt.point(leopard.origin.x + 111*leopard.bbratio, leopard.origin.y),
                Qt.point(leopard.origin.x + 228*leopard.bbratio, leopard.origin.y + 31*leopard.bbratio),
                Qt.point(leopard.origin.x + 284*leopard.bbratio, leopard.origin.y + 89*leopard.bbratio),
                Qt.point(leopard.origin.x + 231*leopard.bbratio, leopard.origin.y + 185*leopard.bbratio),
                Qt.point(leopard.origin.x + 64*leopard.bbratio, leopard.origin.y + 187*leopard.bbratio),
                Qt.point(leopard.origin.x + 13*leopard.bbratio, leopard.origin.y + 60*leopard.bbratio)
            ]
            density: 1
            friction: 1
            restitution: 0.1
        }
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
            visible: true
        }
}
