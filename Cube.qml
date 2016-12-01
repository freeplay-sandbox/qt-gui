import QtQuick 2.2
import Box2D 2.0

import Ros 1.0

Item {
        id:cube
        width: 2*parent.height * physicalCubeSize / physicalMapWidth
        height: width
        rotation: Math.random() * 360

        property string name: ""
        property string image: "res/cube.svg"

        property var boundingbox:
           Box {
                        width: image.paintedWidth
                        height: image.paintedHeight
                        x: cube.width/2 - width/2
                        y: cube.height/2 - height/2
                        density: 1
                        restitution: 0.1
                        friction: 1
                }

        property alias body: cubeBody
        property double bbratio: 1 // set later (cf below) once paintedWidth is known
        property alias origin: imageOrigin

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
            onPaintedWidthChanged: {
                bbratio= image.paintedWidth/image.sourceSize.width;
            }

        }
        Body {
                id: cubeBody

                target: cube
                world: physicsWorld
                bodyType: Body.Dynamic

                Component.onCompleted: {
                    cubeBody.addFixture(cube.boundingbox);
                }

                angularDamping: 5
                linearDamping: 5
        }

        MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: {
                        mouse.accepted = false;
                        pressedBody = cubeBody;
                }
        }
//   PinchArea {
//           anchors.fill: parent
//           pinch.target: parent
//           pinch.minimumRotation: -360
//           pinch.maximumRotation: 360
//           //pinch.minimumScale: 1
//           //pinch.maximumScale: 1
//           pinch.dragAxis: Pinch.XAndYAxis

//           MouseArea {
//                   anchors.fill: parent
//                   drag.target: cube
//                   scrollGestureEnabled: false
//           }
//   }

    Item {
        id: objectCenter
        anchors.centerIn: parent
        rotation: parent.rotation
        TFBroadcaster {
            target: parent
            frame: parent.parent.name

            origin: mapOrigin
            parentframe: "sandtray"

            pixelscale: zoo.pixel2meter
        }
    }


}
