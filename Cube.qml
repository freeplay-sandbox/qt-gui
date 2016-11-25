import QtQuick 2.2
import Box2D 2.0

Item {
        id:cube
        width: 2*parent.height * physicalCubeSize / physicalMapLength
        height: width
        rotation: Math.random() * 360

        property string image: "res/cube.svg"

        property var boundingbox:
           Box {
                        width: cube_texture.paintedWidth
                        height: cube_texture.paintedHeight
                        x: cube.width/2 - width/2
                        y: cube.height/2 - height/2
                        density: 1
                        restitution: 0.1
                        friction: 1
                }


        Image {
            id: cube_texture
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: parent.image

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


}
