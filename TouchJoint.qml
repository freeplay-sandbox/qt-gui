import QtQuick 2.0

import Box2D 2.0

import Ros 1.0

TouchPoint {

    id: touch

    property string name: "touch"
    property bool movingItem: false
    property bool drawing: false

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

    property MouseJoint joint: MouseJoint {
        bodyA: anchor
        dampingRatio: 1
        maxForce: 1
    }

    onXChanged: {

        if(movingItem) {
            joint.target = Qt.point(x, y);
        }

        // (only add stroke point in one dimension (Y) to avoid double drawing)
    }

    onYChanged: {
        if(movingItem) {
            joint.target = Qt.point(x, y);
        }

        if (drawing) {
            currentStroke.push(Qt.point(x,y));
            drawingarea.update();
        }
    }
    onPressedChanged: {

        if (pressed) {

            // find out whether we touched an item
            var obj = interactiveitems.childAt(x, y);
            if (obj.objectName === "interactive") {

                movingItem = true;

                // restack item to the top
                interactiveitems.currentMaxZ += 1;
                obj.z=interactiveitems.currentMaxZ;

                // update the join forces
                joint.maxForce = obj.body.getMass() * 500;
                joint.target = Qt.point(x, y);
                joint.bodyB = obj.body;
            }
            else {
                currentStroke = [];
                color = drawingarea.fgColor;
                drawing = true;
            }

        }
        else { // released
            if(movingItem) {
                joint.bodyB = null;
                movingItem = false;
            }

            if(drawing) {
                drawing = false;
                drawingarea.finishStroke(currentStroke);
                currentStroke = [];
            }
        }
    }

    property var tf: Item {
                        // the TF broadcaster can not directly target 'touch' as TouchPoint is not a QtQuickItem
                        id: touchtracker
                        x: touch.x
                        y: touch.y
                        TFBroadcaster {
                            active: drawing || touch.movingItem
                            target: parent
                            frame: touch.name

                            origin: mapOrigin
                            parentframe: mapOrigin.name
                            pixelscale: sandbox.pixel2meter
                        }
    }


}

