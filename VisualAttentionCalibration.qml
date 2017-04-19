import QtQuick 2.0

import Ros 1.0

Item {

    id: visualtracking

    anchors.fill: parent

    function start() {
        calibratingvisualfocus.signal();
        visualtarget_animation.start();
        rocket_color_animation.start();
    }

    RosSignal {
        id: calibratingvisualfocus
        topic: "visualfocus_calibration"
    }

    Item {
        id: visualtarget
        width:parent.width * 0.05
        height: width

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "res/rocket.svg"

            Image {
                id: alternate_rocket
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: "res/alternate_rocket.svg"
                opacity: 0


                PropertyAnimation {
                    id: rocket_color_animation
                    running:false
                    target: alternate_rocket
                    property: "opacity"
                    duration: 30000
                    to: 1
                }
            }

            Item {
                id: imageOrigin
                x: parent.x + parent.width / 2
                y: parent.y + parent.height / 2

                TFBroadcaster {
                    id: targetTFbroadcaster
                    active: visualtracking.visible
                    target: parent
                    frame: "visual_target"

                    origin: mapOrigin
                    parentframe: "sandtray"

                    pixelscale: sandbox.pixel2meter
                }

                /*
                Rectangle {
                    color:"blue"
                    width: 5
                    height: 5
                    radius: 2
                }
                */
            }
        }


        property int margin: parent.width * 0.05
        property int max_x: parent.width - margin
        property int max_y: parent.height - margin
        property int mid_x: (max_x - margin) / 2 + margin
        property int mid_y: (max_y - margin) / 2 + margin

        property int base_duration: 5000

        x: mid_x
        y: mid_y

        SequentialAnimation {
            id: visualtarget_animation
            running: false
            PauseAnimation { duration: 1500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 215; duration: 2000 }
            ParallelAnimation {
                SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.7 }
                SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.7 }
            }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.max_x; duration: visualtarget.base_duration }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 90; duration: 200 }
            SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.mid_y; duration: visualtarget.base_duration * 0.3 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 200 }
            SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.mid_x; duration: visualtarget.base_duration * 0.5 }
            PauseAnimation { duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 270; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.3}
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 145; duration: 300 }
            ParallelAnimation {
                SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.5 }
                SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.max_y; duration: visualtarget.base_duration * 0.5 }
            }
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 300 }
            SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.mid_x; duration: visualtarget.base_duration * 0.5}
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 270; duration: 500 }
            SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.mid_y; duration: visualtarget.base_duration * 0.3}
            SmoothedAnimation { target: visualtarget; property: "rotation"; to: 720; duration: 1000 }
            NumberAnimation { target: visualtarget; property: "x"; easing.type: Easing.InQuad; easing.period: visualtarget.base_duration; to: visualtarget.max_x + 3 * visualtarget.margin; duration: visualtarget.base_duration}
            PauseAnimation { duration: 1000 }

            onStopped: {
                calibratingvisualfocus.signal();
                visualtracking.visible=false;
                zoo.visible=true;
            }
        }



    }
}
