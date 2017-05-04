import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import Box2D 2.0

import Ros 1.0

Window {

    id: window

    visible: true
    visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:800
    height: 600

    property int prevWidth:800
    property int prevHeight:600

    onWidthChanged: {
        robot.x = robot.x * width/prevWidth;
        prevWidth=width;
    }
    onHeightChanged: {
        robot.y = robot.y * height/prevHeight;
        prevHeight=height;

    }

    color: "black"
    title: qsTr("Free-play sandbox")

    Item {
        id: sandbox
        anchors.fill:parent

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        //property double pixel2meter: (physicalMapWidth / 1000) / drawingarea.paintedWidth
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width

        DrawingArea {
            id: drawingarea
            height: parent.height
            width: parent.width * 0.88
            anchors.left: parent.left
            anchors.top: parent.top

            pixelscale: sandbox.pixel2meter

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: parent.rotation
                x: parent.x // + (parent.width - parent.paintedWidth)/2
                y: parent.y //+ (parent.height - parent.paintedHeight)/2
            }
           RosSignal {
                id: backgrounddrawing
                topic: "sandtray_drawing"
           }
           onDrawEnabledChanged: backgrounddrawing.signal()
        }

        Rectangle {
            id: stash
            color: "black"
            height: parent.height
            width: parent.width - drawingarea.width
            anchors.left: drawingarea.right
            anchors.top: parent.top

            Rectangle {
               height: parent.height
                width: 5
                anchors.left: parent.left
                anchors.top: parent.top
                color: "#555"

            }
        }

        Item {
            id: interactiveitems

            anchors.fill: parent


            property bool showRobotChild: false
            property bool publishRobotChild: false

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            MouseJoint {
                id: externalJoint
                bodyA: anchor
                dampingRatio: 1
                maxForce: 1
            }

            MultiPointTouchArea {
                id: mouseArea
                anchors.fill: parent

                enabled: parent.opacity < 0.5 ? false : true

                touchPoints: [
                    TouchJoint {},
                    TouchJoint {},
                    TouchJoint {},
                    TouchJoint {},
                    TouchJoint {},
                    TouchJoint {}
                ]
            }

            Item {
                id:robot
                z:100
                rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-robot.y+robotFocus.y, -robot.x+robotFocus.x))
                Image {
                    id: robotImg
                    source: "res/nao_head.svg"
                    anchors.centerIn: parent
                    width: 100
                    fillMode: Image.PreserveAspectFit

                    Drag.active: robotDragArea.drag.active

                    MouseArea {
                        id: robotDragArea
                        anchors.fill: parent
                        drag.target: robot
                    }
                    visible:interactiveitems.publishRobotChild
                }

                TFBroadcaster {
                    active: interactiveitems.publishRobotChild
                    target: parent
                    frame: "odom"

                    origin: mapOrigin
                    parentframe: mapOrigin.name

                    //zoffset: -0.15 // on boxes, next to sandtray
                    zoffset: -0.25 // on the ground, next to sandtray

                    pixelscale: sandbox.pixel2meter
                }




            }
            TFListener {
                id: robotArmReach
                x: window.width/2
                y: window.height/2
                z:100

                visible: interactiveitems.showRobotChild

                frame: "arm_reach"
                origin: mapOrigin
                parentframe: mapOrigin.name
                pixelscale: sandbox.pixel2meter

                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: width
                    radius: width/2
                    color: "red"
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.zvalue * 2 / sandbox.pixel2meter
                    height: width
                    radius: width/2
                    color: "#55FFAA44"
                }
            }
            Item {
                id: robotFocus
                x: window.width/2
                y: window.height/2
                z:100

                Rectangle {
                    anchors.centerIn: parent
                    width:30
                    height: width
                    radius: width/2
                    color: "#FF3333"

                    Drag.active: robotFocusDragArea.drag.active

                    MouseArea {
                        id: robotFocusDragArea
                        anchors.fill: parent
                        drag.target: robotFocus
                    }

                    visible: interactiveitems.showRobotChild

                    TFBroadcaster {
                        active: parent.visible
                        target: parent
                        frame: "robot_focus"

                        origin: mapOrigin
                        parentframe: mapOrigin.name

                        pixelscale: sandbox.pixel2meter
                    }
                }
            }

            Item {
                id: childFocus
                x: window.width/2
                y: window.height/2
                z:100

                Rectangle {
                    anchors.centerIn: parent
                    width:30
                    height: width
                    radius: width/2
                    color: "#995500"

                    Drag.active: childFocusDragArea.drag.active

                    MouseArea {
                        id: childFocusDragArea
                        anchors.fill: parent
                        drag.target: childFocus
                    }
                    visible: interactiveitems.publishRobotChild

                }
            }

            RosPoseSubscriber {
                id: gazeFocus
                x: window.width/2
                y: window.height/2
                z:100

                visible: false

                topic: "/gazepose_0"
                origin: mapOrigin
                pixelscale: sandbox.pixel2meter

                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: width
                    radius: width/2
                    color: "red"
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.zvalue * 2 / sandbox.pixel2meter
                    height: width
                    radius: width/2
                    color: "transparent"
                    border.color: "orange"
                }
            }

            Item {
                id:child
                z:100
                rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-child.y+childFocus.y, -child.x+childFocus.x))
                Image {
                    id: childImg
                    source: "res/child_head.svg"
                    anchors.centerIn: parent
                    width: 100
                    fillMode: Image.PreserveAspectFit

                    Drag.active: childDragArea.drag.active

                    MouseArea {
                        id: childDragArea
                        anchors.fill: parent
                        drag.target: child
                    }
                    visible: interactiveitems.publishRobotChild
                }

                TFBroadcaster {
                    active: interactiveitems.publishRobotChild
                    target: parent
                    frame: "child"

                    origin: mapOrigin
                    parentframe: mapOrigin.name

                    pixelscale: sandbox.pixel2meter
                }


                x: window.width/2 - childImg.width /2
                y: window.height - childImg.height
            }

            RosPoseSubscriber {
                id: rostouch

                x: childFocus.x
                y: childFocus.y

                topic: "poses"

                Image {
                    id:robot_hand
                    source: "res/nao_hand.svg"
                    y: - 10
                    x: - 30
                    width: 120
                    fillMode: Image.PreserveAspectFit
                    // tracks the position of the robot
                    transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(robotArmReach.y-rostouch.y, robotArmReach.x-rostouch.x))}
                    visible: false

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
                pixelscale: sandbox.pixel2meter

                onPositionChanged: {

                    // the playground is hidden, nothing to do
                    if(!interactiveitems.visible) return;

                    robot_hand.visible=true;

                    if (target === null) {
                        var obj = interactiveitems.childAt(x, y);
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
                    interval: 1000
                    running: false
                    onTriggered: {
                        console.log("Auto-releasing ROS contact with " + parent.draggedObject);
                        releasingItem.text = parent.draggedObject;
                        parent.draggedObject = "";
                        parent.target = null;
                        externalJoint.bodyB = null;
                        robot_hand.visible=false;
                    }
                }
                RosStringPublisher {
                    id: releasingItem
                    topic: "releasing"
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
                stash: stash
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
                stash: stash
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
                stash: stash
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
                stash: stash
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
                stash: stash
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
                stash: stash
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
                stash: stash
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
                stash: stash
            }

            Character {
                id: toychild1
                name: "toychild1"
                image: "res/child_1.svg"
                stash: stash
            }
            Character {
                id: toychild4
                name: "toychild4"
                image: "res/child_4.svg"
                stash: stash
            }



            FootprintsPublisher {
                id:footprints
                pixelscale: sandbox.pixel2meter

                // wait a bit before publishing the footprints to leave Box2D the time to settle
                Timer {
                    interval: 1000; running: true; repeat: false
                    onTriggered: parent.targets=interactiveitems.getActiveItems()
                }
            }

            function getActiveItems() {
                var targets= [zebra,elephant,leopard,lion,giraffe,rhino,crocodile,hippo,toychild1, toychild4];
                for (var childIdx=0; childIdx < interactiveitems.children.length; childIdx++) {
                    var child = interactiveitems.children[childIdx];
                    if("name" in child)
                        if (child.name.substr(0,5) === "cube_") {
                            targets.push(child);
                        }
                }
                return targets;

            }
        }
    }

    Image {
        id: drawModeButton
        source: "res/paint-brush.svg"
        width: 100
        height: width
        rotation: -90
        anchors.verticalCenter: parent.verticalCenter
        x: 30
        visible: opacity === 0 ? false : true

        Behavior on opacity {
            NumberAnimation {
                duration:300
            }
        }

        MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.opacity = 0.4;
                    drawModeButton.opacity = 0;
                    drawingarea.drawEnabled = true;

                }
            }

    }

    Item {
        id: debugToolbar
        x:0
        y:0
        visible:false

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
            id: visualAttentionButton
            x: 250
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start visual target tracking"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.visible = false;
                    debugToolbar.visible = false;
                    visualtracking.visible = true;
                    visualtracking.start();
                }
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
                }
            }
        }
        Rectangle {
            id: robotButton
            x: 50
            y: 150
            width: 180
            height: 30
            Text {
                text: interactiveitems.showRobotChild ? "Hide robot/child" : "Control robot/child"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.showRobotChild = !interactiveitems.showRobotChild;
                    if (interactiveitems.showRobotChild) {
                        robot.x=window.width - robotImg.width;
                        robot.y=window.height / 2 - robotImg.height / 2;
                    }
                }
            }
        }
        Rectangle {
            id: robotPublisherButton
            x: 50
            y: 200
            width: 180
            height: 30
            Text {
                text: interactiveitems.publishRobotChild ? "Stop publishing robot/child frames" : "Publish robot/child frames"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {interactiveitems.publishRobotChild = !interactiveitems.publishRobotChild;}
            }
        }
        Rectangle {
            id: gazeButton
            x: 50
            y: 250
            width: 180
            height: 30
            Text {
                text: gazeFocus.visible ? "Hide gaze" : "Show gaze"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gazeFocus.visible = !gazeFocus.visible;
                }
            }
        }
    }

    DebugDraw {
        id: debugDraw
        world: physicsWorld
        opacity: 0.75
        visible: false
    }

    Image {
        id: fiducialmarker
        // set the actual size of the SVG page
        width: 0.60 / sandbox.pixel2meter
        height: 0.33 / sandbox.pixel2meter
        // make sure the image is in the corner ie, the sandtray origin
        x: 0
        y: 0
        fillMode: Image.PreserveAspectCrop
        source: "res/tags/markers.svg"
        visible: false

    }

    VisualAttentionCalibration {
        id: visualtracking
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
                interactiveitems.visible = false;
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
                interactiveitems.visible = true;
            }

        }

        RosSignal {
            id: localising
            topic: "sandtray_localising"
        }
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.left: parent.left

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                debugToolbar.visible=true;
                clicks = 0;
                timerHideDebug.start();
            }
        }

        Timer {
            id: timerHideDebug
            interval: 5000; running: false; repeat: false
            onTriggered: {
                debugToolbar.visible = false;
            }

        }
    }

}
