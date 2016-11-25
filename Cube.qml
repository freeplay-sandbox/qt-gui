import QtQuick 2.2
import Box2D 2.0

Item {
        id:cube
        width: parent.height * physicalCubeSize / physicalMapLength
        height: width
        rotation: Math.random() * 360

        Image {
                id: cube_texture
                anchors.fill: parent
                source: "res/cube.svg"

        }
        Body {
                id: cubeBody

                target: cube
                world: physicsWorld
                bodyType: Body.Dynamic

                Box {
                        width: cube.width
                        height: cube.height
                        density: 1
                        restitution: 0.1
                        friction: 1
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


}
