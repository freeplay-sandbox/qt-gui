import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

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
        visible: true

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
            visible: true

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
                topic: "sandtray/signals/background_drawing"
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

            visible: true

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
                id: touchArea
                anchors.fill: parent

                touchPoints: [
                    TouchJoint {id:touch1;name:"touch1"},
                    TouchJoint {id:touch2;name:"touch2"},
                    TouchJoint {id:touch3;name:"touch3"},
                    TouchJoint {id:touch4;name:"touch4"},
                    TouchJoint {id:touch5;name:"touch5"},
                    TouchJoint {id:touch6;name:"touch6"}
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
                            interactionEventsPub.text = "robottouching_" + draggedObject;

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
                        interactionEventsPub.text = "robotreleasing_" + parent.draggedObject;
                        var items = interactiveitems.getActiveItems()
                        for(var i = 0;i<items.length;i++)
                            if(items[i].name === parent.draggedObject)
                                items[i].testCloseImages()
                        parent.draggedObject = "";
                        parent.target = null;
                        externalJoint.bodyB = null;
                        robot_hand.visible=false;
                    }
                }
                RosStringPublisher {
                    id: interactionEventsPub
                    topic: "sandtray/interaction_events"
                }
                RosStringSubscriber {
                    id: interactionEventsSub
                    topic: "sandtray/interaction_events"
                    onTextChanged: {
                        if(text === "supervisor_ready")
                            publishItems();
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

            StaticImage{
                id: hay
                name: "hay"
                image: "res/hay.png"
                x: 200
                y: 200
            }
            StaticImage{
                id: steak
                name: "steak"
                image: "res/steak.png"
                x: 600
                y: 200
            }
            Character {
                id: horse
                name: "horse"
                image: "res/horse.png"
                eatingFood: "hay"
                stash: stash
            }
            Character {
                id: cow
                name: "cow"
                image: "res/cow.png"
                eatingFood: "hay"
                stash: stash
            }
            Character {
                id: dog
                name: "dog"
                image: "res/dog.png"
                eatingFood: "steak"
                stash: stash
            }
            Character {
                id: cat
                name: "cat"
                image: "res/cat.png"
                eatingFood: "steak"
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
                return [horse, cow, dog, cat]
            }
            function getStaticItems() {
                return [hay, steak]
            }

            function hideItems(items) {
                for (var i = 0; i < items.length; i++) {
                    items[i].visible = false;
                }
            }

            function restoreAllItems() {
                var items = getActiveItems();
                for (var i = 0; i < items.length; i++) {
                    items[i].visible = true;
                }
            }

            function shuffleItems() {
                var items = getActiveItems();
                for(var i = 0; i < items.length; i++) {
                    var item = items[i]
                    item.x = interactiveitems.x + interactiveitems.width * 0.1 + Math.random() * 0.8 * interactiveitems.width;
                    item.y = interactiveitems.y + interactiveitems.height * 0.1 + Math.random() * 0.8 * interactiveitems.height;
                    item.rotation = Math.random() * 360;
                 }
            }

            RosSignal {
                topic: "sandtray/signals/shuffle_items"
                onTriggered: interactiveitems.shuffleItems();
            }


            function itemsToStash() {
                var items = getActiveItems();
                for(var i = 0; i < items.length; i++) {
                    var item = items[i]
                    item.x = item.stash.x + 10 + Math.random() * 0.5 * item.stash.width;
                    item.y = item.stash.y + 10 + Math.random() * 0.9 * item.stash.height;
                    item.rotation = Math.random() * 360;
               }
            }


            function startFreeplay() {
                itemsToStash();
                interactiveitems.restoreAllItems();
            }

            RosSignal {
                topic: "sandtray/signals/items_to_stash"
                onTriggered: interactiveitems.itemsToStash();
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
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "visualtracking";
                }
            }
        }
        Rectangle {
            id: tutorialButton
            x: 550
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start tutorial"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "tutorial";
                }
            }

        }
        Rectangle {
            id: freeplayButton
            x: 850
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start freeplay"
                anchors.centerIn: parent
            }
            color: "#FFDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugToolbar.visible = false;
                    globalstates.state = "freeplay-sandbox";
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

    Rectangle {
        id: fiducialmarker
        color:"white"
        opacity:0.8
        visible: false
        anchors.fill:parent

        Image {
            // set the actual size of the SVG page
            width: 0.60 / sandbox.pixel2meter
            height: 0.33 / sandbox.pixel2meter
            // make sure the image is in the corner ie, the sandtray origin
            x: 0
            y: 0
            fillMode: Image.PreserveAspectCrop
            source: "res/tags/markers.svg"

        }

        RosSignal {
            id: localising
            topic: "sandtray/signals/robot_localising"
            onTriggered: {
                    fiducialmarker.visible=true;
                    hide_fiducial_markers.start();
            }
        }

        Timer {
            id: hide_fiducial_markers
            interval: 5000; running: false; repeat: false
            onTriggered: {
                fiducialmarker.visible = false;
            }

        }

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
                fiducialmarker.visible = true;
                clicks = 0;
                hide_fiducial_markers.start();
            }
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
    Timer {
        id: initialise
        interval: 900; running: false; repeat: false
        onTriggered: {
            startFreeplay()
        }
    }

    Timer {
        id: hunger
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var items = interactiveitems.getActiveItems()
            var list=[]
            for(var i = 0; i < items.length; i++){
                items[i].life -= 0.01
                list.push(items[i].life)
            }
            lifePub.list = list
            lifePub.publish()
        }
    }

    RosListFloatPublisher{
        id: lifePub
        topic: "sparc/partial_state"
    }

    function publishItems(){
        var message = "characters"
        var items = interactiveitems.getActiveItems()
        for(var i = 0; i < items.length; i++)
            message += "_"+items[i].name
        interactionEventsPub.text = message
        sleep(100)
        message = "targets"
        items = interactiveitems.getStaticItems()
        for(var i = 0; i < items.length; i++)
            message += "_"+items[i].name
        sleep(100)
        interactionEventsPub.text = message
    }
    }

}
