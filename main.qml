import QtQuick 2.2
import QtQuick.Window 2.2

import Box2D 2.0

import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:800
    height: 600
    color: "black"
    title: qsTr("Zoo Builder")

    Item {
        id: zoo

        anchors.fill: parent

        property double physicalMapWidth: 600 //mm
        property double physicalCubeSize: 30 //mm
        property double pixel2meter: (physicalMapWidth / 1000) / map.paintedWidth

        property int nbCubes: 10

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
                if (zoo.pressedBody != null) {
                    mouseJoint.maxForce = zoo.pressedBody.getMass() * 500;
                    mouseJoint.target = Qt.point(mouseX, mouseY);
                    mouseJoint.bodyB = zoo.pressedBody;
                }
            }

            onPositionChanged: {
                mouseJoint.target = Qt.point(mouseX, mouseY);
            }

            onReleased: {
                mouseJoint.bodyB = null;
                zoo.pressedBody = null;
            }
        }

        Item {
            id:robot
            z:100
            Image {
                id: robotImg
                source: "res/nao_head.svg"
                anchors.centerIn: parent
                width: 100
                fillMode: Image.PreserveAspectFit
                rotation: 180+180/Math.PI * (-Math.PI/2 + Math.atan2(-robot.y+rostouch.y, -robot.x+rostouch.x))

                Drag.active: robotDragArea.drag.active

                MouseArea {
                    id: robotDragArea
                    anchors.fill: parent
                    drag.target: robot
                }
            }

            TFBroadcaster {
                target: robotImg
                frame: "base_footprint"

                origin: mapOrigin
                parentframe: "sandtray"

                pixelscale: zoo.pixel2meter
            }

            x: window.width - robotImg.width
            y: window.height / 2 - robotImg.height / 2
        }

        Item {
            id: childFocus
            x: window.width/2
            y: window.height/2
        }

        Item {
            id:child
            z:100
            Image {
                id: childImg
                source: "res/child_head.svg"
                anchors.centerIn: parent
                width: 100
                fillMode: Image.PreserveAspectFit
                rotation: 180+180/Math.PI * (-Math.PI/2 + Math.atan2(-child.y+childFocus.y, -child.x+childFocus.x))

                Drag.active: childDragArea.drag.active

                MouseArea {
                    id: childDragArea
                    anchors.fill: parent
                    drag.target: child
                }
            }

            TFBroadcaster {
                target: childImg
                frame: "child"

                origin: mapOrigin
                parentframe: "sandtray"

                pixelscale: zoo.pixel2meter
            }


            x: window.width/2 - childImg.width /2
            y: window.height - childImg.height
        }

        RosPose {
            id: rostouch

            Image {
               source: "res/nao_hand.svg"
               y: - 5
               x: - 15
               width: 60
               fillMode: Image.PreserveAspectFit
               // tracks the position of the robot
               transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(robot.y-rostouch.y, robot.x-rostouch.x))}

            }
            //Rectangle {
            //    anchors.centerIn: parent
            //    width: 5
            //    height: width
            //    radius: width/2
            //    color: "red"
            //    z:1
            //}

            z:100
            property var target: null
            property string draggedObject: ""
            origin: mapOrigin
            pixelscale: zoo.pixel2meter

            onPositionChanged: {

                // the playground is hidden, nothing to do
                if(!zoo.visible) return;

                if (target === null) {
                    var obj = zoo.childAt(x, y);
                    if (obj.objectName === "interactive") {
                        draggedObject = obj.name;
                        console.log("ROS controller touched object: " + obj.name);

                        target = obj.body

                        externalJoint.maxForce = target.getMass() * 500;
                        externalJoint.target = Qt.point(x,y);
                        externalJoint.bodyB = target;
                    }

                }
                if (target != null) {
                    externalJoint.target = Qt.point(x, y);
                    releasetimer.restart();
                }
            }

            Timer {
                id: releasetimer
                    interval: 2000
                    running: false
                    onTriggered: {
                        console.log("Auto-releasing ROS contact with " + parent.draggedObject);
                        parent.draggedObject = "";
                        parent.target = null;
                        externalJoint.bodyB = null;
                    }
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
            model: zoo.nbCubes
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
            //Component.onCompleted: footprints.targets.push(zebra)
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

        Character {
            id: toychild1
            name: "toychild1"
            image: "res/child_1.png"
            scale:0.5
            boundingbox: Polygon {
                vertices: [
                    Qt.point(toychild1.origin.x + 93*toychild1.bbratio, toychild1.origin.y),
                    Qt.point(toychild1.origin.x + 181*toychild1.bbratio, toychild1.origin.y + 27*toychild1.bbratio),
                    Qt.point(toychild1.origin.x + 175*toychild1.bbratio, toychild1.origin.y + 122*toychild1.bbratio),
                    Qt.point(toychild1.origin.x + 15*toychild1.bbratio, toychild1.origin.y + 122*toychild1.bbratio),
                    Qt.point(toychild1.origin.x,  toychild1.origin.y + 32*toychild1.bbratio)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }
        }
        Character {
            id: toychild4
            name: "toychild4"
            image: "res/child_4.png"
            scale:0.5
            boundingbox: Polygon {
                vertices: [
                    Qt.point(toychild4.origin.x + 93*toychild4.bbratio, toychild4.origin.y),
                    Qt.point(toychild4.origin.x + 181*toychild4.bbratio, toychild4.origin.y + 27*toychild4.bbratio),
                    Qt.point(toychild4.origin.x + 175*toychild4.bbratio, toychild4.origin.y + 142*toychild4.bbratio),
                    Qt.point(toychild4.origin.x + 15*toychild4.bbratio, toychild4.origin.y + 142*toychild4.bbratio),
                    Qt.point(toychild4.origin.x,  toychild4.origin.y + 32*toychild4.bbratio)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }
        }



        FootprintsPublisher {
            id:footprints
            pixelscale: zoo.pixel2meter
        }

        Rectangle {
            id: fullscreenButton
            x: 50
            y: 50
            width: 180
            height: 30
            Text {
                text:  "Toggle fullscreen"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: (window.visibility === Window.FullScreen) ? window.visibility = Window.Windowed : window.visibility = Window.FullScreen;
            }
        }
        Rectangle {
            id: debugButton
            x: 50
            y: 100
            width: 180
            height: 30
            Text {
                text: debugDraw.visible ? "Physics debug: on" : "Physics debug: off"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugDraw.visible = !debugDraw.visible;
                    var targets= [zebra,elephant,leopard,lion,giraffe,rhino,crocodile,hippo,toychild1, toychild4];
                    for (var childIdx=0; childIdx < zoo.children.length; childIdx++) {
                        var child = zoo.children[childIdx];
                        if("name" in child)
                            if (child.name.substr(0,5) === "cube_") {
                            targets.push(child);
                            }
                    }

                    footprints.targets = targets;
            }
            }
        }

        DebugDraw {
            id: debugDraw
            world: physicsWorld
            opacity: 0.75
            visible: false
        }
    }

    Image {
        id: fiducialmarker
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        source: "res/709.png"
        visible: false
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                localising.signal();
                zoo.visible = false;
                window.color = "white";
                fiducialmarker.visible = true;
                clicks = 0;
                restore.start();
            }
        }

        Timer {
            id: restore
            interval: 5000; running: false; repeat: false
            onTriggered: {
                fiducialmarker.visible = false;
                window.color = "black"
                zoo.visible = true;
            }

        }

        RosSignal {
            id: localising
            topic: "sandtray_localising"
        }
    }

}
