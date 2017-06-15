import QtQuick 2.2
import Box2D 2.0

import Ros 1.0

Item {
        id:cube
        width: 1.5 * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
        height: width
        rotation: Math.random() * 360

        objectName: "interactive"

        property string name
        property string image

        property var boundingbox:
            Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(origin.x, origin.y),
                    Qt.point(origin.x + image.sourceSize.width * bbratio, origin.y),
                    Qt.point(origin.x + image.sourceSize.width * bbratio, origin.y + image.sourceSize.height * bbratio),
                    Qt.point(origin.x, origin.y + image.sourceSize.height * bbratio),
                ]
                density: 1
                friction: 1
                restitution: 0.1
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
            active: sandbox.visible

            origin: mapOrigin
            parentframe: mapOrigin.name

            pixelscale: sandbox.pixel2meter
        }
    }

    function isIn(tx, ty) {
        return (tx > x) && (tx < x + width) && (ty > y) && (ty < y + height);
    }

}
