import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

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
        prevWidth=width;
    }
    onHeightChanged: {
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
        property int livingAnimals: 10
        property double totalLife: eagle.life + wolf.life + rat.life + python.life + bird.life + frog.life + dragonfly.life + fly.life + butterfly.life + grasshopper.life
        property double points: 0
        property var startingTime: 0

        onLivingAnimalsChanged: {
            if(livingAnimals == 0){
                transitionScreen.visible = true
            }
        }

        Item {
            id: transitionScreen
            anchors.fill: parent
            visible: false
            z: 10

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width / 2
                height: parent.height / 2
                color: "AliceBlue"
                border.color: "black"
                border.width: width/100
                radius: width / 10
                Label {
                    id: lab
                    font.pixelSize: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            onVisibleChanged: {
                var d = new Date()
                console.log(sandbox.startingTime)
                var n = d.getTime() - sandbox.startingTime
                lab.text = "You had animals for "+Number(n).toLocaleString()+" seconds \n Well done!"

            }
        }

        DrawingArea {
            id: drawingarea
            height: parent.height
            width: parent.width
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

        Label {
            id: animalCounter
            text: "Living animals: " + sandbox.livingAnimals
            font.pixelSize: 40
            anchors.top:parent.top
            anchors.left:parent.left
        }
        Label {
            id: lifeCounter
            text: "Total life: " + Number(sandbox.totalLife).toLocaleString()
            anchors.top:animalCounter.bottom
            font.pixelSize: 40
            anchors.left:parent.left
        }
        Label {
            text: "Points: " + Number(sandbox.points).toLocaleString()
            anchors.top:lifeCounter.bottom
            font.pixelSize: 40
            anchors.left:parent.left
        }

        Rectangle {
            id: stash
            color: "black"
            height: parent.height
            width: parent.width *.12
            anchors.right: parent.right
            anchors.top: parent.top
            visible: false

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

            property var collisionCategories: Box.Category2

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

            RosPoseSubscriber {
                id: rostouch

                x: 0
                y: 0

                topic: "poses"

                Image {
                    id:robot_hand
                    source: "res/nao_hand.svg"
                    y: - 10
                    x: - 30
                    width: 120
                    fillMode: Image.PreserveAspectFit
                    // tracks the position of the robot
                    transform: Rotation {origin.x: 15;origin.y: 5;angle: 180/Math.PI * (-Math.PI/2 + Math.atan2(rostouch.y, rostouch.x))}
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
                        for(var i = 0;i<items.length;i++){
                            if(items[i].name === parent.draggedObject){
                                items[i].testCloseImages()
                                items[i].checkProximity()
                            }
                        }
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
                categories: Box.Category2
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
                categories: Box.Category2
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
                categories: Box.Category2
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
                categories: Box.Category2
            }

            Body {
                id: anchor
                world: physicsWorld
            }

            StaticImage{
                id: flower
                name: "flower"
                x: 200
                y: 200
            }
            StaticImage{
                id: lavender
                name: "lavender"
                x: 600
                y: 200
            }
            StaticImage{
                id: mango
                name: "mango"
                x: 400
                y: 200
            }

            StaticImage{
                id: corn
                name: "corn"
                x: 800
                y: 200
            }

            Character {
                id: grasshopper
                name: "grasshopper"
                food: "corn"
                scale:.8
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: butterfly
                name: "butterfly"
                food: ["flower","lavender"]
                scale:.8
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: fly
                name: "fly"
                food: "mango"
                scale: 0.5
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: bird
                name: "bird"
                food: ["dragonfly","fly"]
                scale:.9
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: dragonfly
                name: "dragonfly"
                food: ["butterfly","fly"]
                scale:.8
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: frog
                name: "frog"
                food: ["grasshopper","butterfly","dragonfly","fly"]
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: eagle
                name: "eagle"
                food: ["python","rat","wolf","frog","bird"]
                stash: stash
                scale:1.5
                collidesWith: interactiveitems.collisionCategories
            }
            Character {
                id: rat
                name: "rat"
                food: "grasshopper"
                stash: stash
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: wolf
                name: "wolf"
                food: ["rat","bird"]
                stash: stash
                scale:1.5
                collidesWith: interactiveitems.collisionCategories
            }

            Character {
                id: python
                name: "python"
                food: ["rat","frog","wolf"]
                stash: stash
                scale:1.5
                collidesWith: interactiveitems.collisionCategories
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
                return [eagle, wolf, rat, python,bird,frog,dragonfly,fly,butterfly,grasshopper]
            }
            function getStaticItems() {
                return [lavender, flower, mango, corn]
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
            function itemsToRandom(items) {
                for(var i = 0; i < items.length; i++) {
                    items[i].relocate()
                    items[i].rotation = Math.random() * 360;
               }
            }


            function startFoodChain() {
                itemsToRandom(getActiveItems());
                itemsToRandom(getStaticItems());
                interactiveitems.restoreAllItems();

                var d = new Date()
                sandbox.startingTime = d.getTime()
            }

            RosSignal {
                topic: "sandtray/signals/items_to_stash"
                onTriggered: interactiveitems.itemsToStash();
            }



        }
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
        interval: 200; running: true; repeat: false
        onTriggered: {
            interactiveitems.startFoodChain()
        }
    }

    Timer {
        id: hunger
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var items = interactiveitems.getActiveItems()
            var list=[]
            for(var i = 0; i < items.length; i++){
                if(items[i].life>0)
                    items[i].life -= 0.01
                list.push(items[i].life)
            }
            lifePub.list = list
            lifePub.publish()
            sandbox.points += sandbox.totalLife
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
            message += "_"+items[i].name + "-" + items[i].scale
        interactionEventsPub.text = message
        sleep(100)
        message = "targets"
        items = interactiveitems.getStaticItems()
        for(var i = 0; i < items.length; i++)
            message += "_"+items[i].name + "-" + items[i].scale
        sleep(100)
        interactionEventsPub.text = message
    }

    function sleep(milliseconds) {
      var start = new Date().getTime();
      for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
          break;
        }
      }
    }
}
