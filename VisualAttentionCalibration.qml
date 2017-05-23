import QtQuick 2.0

import Ros 1.0

Item {

    id: visualtracking

    anchors.fill: parent

    function start() {
        visualtarget.reset();
        visualtarget.prepare_animation();
        calibratingvisualfocus_started.signal();
        visualtarget_animation.restart();
        rocket_color_animation.restart();
    }

    RosSignal {
        id: calibratingvisualfocus_started
        topic: "sandtray/signals/visual_tracking_calibration_started"
    }

    RosSignal {
        id: calibratingvisualfocus_ended
        topic: "sandtray/signals/visual_tracking_calibration_ended"
    }


    Item {
        id: visualtarget
        width:parent.width * 0.05
        height: width

        property int margin: parent.width * 0.05
        property int min_x: margin
        property int min_y: margin
        property int max_x: parent.width - margin
        property int max_y: parent.height - margin
        property int mid_x: (max_x - min_x) / 2 + min_x
        property int mid_y: (max_y - min_y) / 2 + min_y

        property int base_duration: 5000 // duration in ms to cross the width of the screen
        property int base_rotation_duration: 1000 // duration in ms for a 180deg rotation
        property int total_duration: 30000 // approximate total duration of the animation, in ms

        x: mid_x
        y: mid_y

        function reset() {
           x = mid_x;
           y = mid_y;
           rotation = 0;
           alternate_rocket.opacity = 0;
        }

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
                    duration: visualtarget.total_duration
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


        function get_rotation(kp1, kp2) {
            var angle = Math.atan2(kp2.y - kp1.y, kp2.x - kp1.x);
            var normalizedAngle = Math.atan2(Math.sin(angle), Math.cos(angle));
            return normalizedAngle * 180 / Math.PI;

        }

        function get_duration(kp1, kp2) {

            var dist = Math.sqrt(Math.pow(kp1.x - kp2.x, 2) + Math.pow(kp1.y - kp2.y, 2));
            return base_duration * dist/(max_x - min_x);

        }

        function get_rotation_duration(angle1, angle2) {

            return base_rotation_duration * Math.abs(angle2-angle1)/180;

        }


        function prepare_animation() {
            var keypoints = [Qt.point(min_x, min_y), Qt.point(mid_x, min_y), Qt.point(max_x, min_y),
                             Qt.point(min_x, mid_y), Qt.point(mid_x, mid_y), Qt.point(max_x, mid_y),
                             Qt.point(min_x, max_y), Qt.point(mid_x, max_y), Qt.point(max_x, max_y)]


            var current_duration = 0;

            var prev_kp = Qt.point(visualtarget.x, visualtarget.y);
            var prev_rotation = visualtarget.rotation

            var animations = [createPauseAnimation(visualtarget_animation,1500),
                              createSmoothedAnimation(visualtarget_animation, visualtarget, "rotation", 180, 500),
                              createSmoothedAnimation(visualtarget_animation, visualtarget, "rotation", 0, 500),
                             ];

            while (current_duration < total_duration) {
                var next_kp = keypoints[Math.floor(Math.random()*keypoints.length)];

                // ensure we select a different keypoint
                while (next_kp === prev_kp) {
                    next_kp = keypoints[Math.floor(Math.random()*keypoints.length)];
                }

                var duration = get_duration(prev_kp, next_kp);

                var next_rotation = get_rotation(prev_kp, next_kp);
                //console.log("From point " + prev_kp + " to " + next_kp + ": duration:" + duration + "ms; target angle: " + next_rotation);
                animations.push(createSmoothedAnimation(visualtarget_animation, visualtarget, "rotation", next_rotation, get_rotation_duration(next_rotation, prev_rotation)));
                animations.push(createMoveAnimation(visualtarget_animation, visualtarget, next_kp, next_rotation, duration));
                current_duration += duration;
                prev_rotation = next_rotation;
                prev_kp = next_kp;

            }

            // go back to the center of the screen...
            next_kp = Qt.point(mid_x, mid_y);
            next_rotation = get_rotation(prev_kp, next_kp);
            duration = get_duration(prev_kp, next_kp);
            animations.push(createMoveAnimation(visualtarget_animation, visualtarget, next_kp, next_rotation, duration));
            // ...and escape on the right side
            animations.push(createSmoothedAnimation(visualtarget_animation, visualtarget, "rotation", 720, 1000));
            animations.push(createMoveAnimation(visualtarget_animation, visualtarget, Qt.point(max_x + 3 * margin, mid_y), 720, base_duration));

            //NumberAnimation { target: visualtarget; property: "x"; easing.type: Easing.InQuad; easing.period: visualtarget.base_duration; to: visualtarget.max_x + 3 * visualtarget.margin; duration: visualtarget.base_duration}

            visualtarget_animation.animations = animations;
        }

        function createMoveAnimation(parent, target, to, angle, duration) {
            var panimation = Qt.createQmlObject("import QtQuick 2.2; ParallelAnimation {}", parent);

            var xanim = createSmoothedAnimation(panimation, target, "x", to.x, duration);
            var yanim = createSmoothedAnimation(panimation, target, "y", to.y, duration);

            panimation.animations = [xanim, yanim];

            return panimation;

        }

        function createSmoothedAnimation(parent, target, prop, to, duration) {
            var animation = Qt.createQmlObject("import QtQuick 2.2; SmoothedAnimation {}", parent);
            animation.to = to;
            animation.target = target;
            animation.property = prop;
            animation.duration = duration;
            return animation;
        }

        function createPauseAnimation(parent, duration) {
            var animation = Qt.createQmlObject("import QtQuick 2.2; PauseAnimation {}", parent);
            animation.duration = duration;
            return animation;
        }

        SequentialAnimation {
            id: visualtarget_animation
            running: false
            //PauseAnimation { duration: 1500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 215; duration: 2000 }
            //ParallelAnimation {
            //    SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.7 }
            //    SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.7 }
            //}
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.max_x; duration: visualtarget.base_duration }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 90; duration: 200 }
            //SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.mid_y; duration: visualtarget.base_duration * 0.3 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 200 }
            //SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.mid_x; duration: visualtarget.base_duration * 0.5 }
            //PauseAnimation { duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 180; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 270; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.3}
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 145; duration: 300 }
            //ParallelAnimation {
            //    SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.margin; duration: visualtarget.base_duration * 0.5 }
            //    SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.max_y; duration: visualtarget.base_duration * 0.5 }
            //}
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 0; duration: 300 }
            //SmoothedAnimation { target: visualtarget; property: "x"; to: visualtarget.mid_x; duration: visualtarget.base_duration * 0.5}
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 270; duration: 500 }
            //SmoothedAnimation { target: visualtarget; property: "y"; to: visualtarget.mid_y; duration: visualtarget.base_duration * 0.3}
            //SmoothedAnimation { target: visualtarget; property: "rotation"; to: 720; duration: 1000 }
            //NumberAnimation { target: visualtarget; property: "x"; easing.type: Easing.InQuad; easing.period: visualtarget.base_duration; to: visualtarget.max_x + 3 * visualtarget.margin; duration: visualtarget.base_duration}

            onStopped: {
                calibratingvisualfocus_ended.signal();
            }
        }

    }
}
