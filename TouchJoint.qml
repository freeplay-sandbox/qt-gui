import QtQuick 2.0

import Box2D 2.0

TouchPoint {

    property var touchedItem

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

    property MouseJoint joint: MouseJoint {
        bodyA: anchor
        dampingRatio: 1
        maxForce: 1
    }

    onXChanged: {

        if(touchedItem) {
            joint.target = Qt.point(x, y);
        }
        else {
            //only add stroke point in one dimension (Y) to avoid double drawing
            //drawingarea.addPoint(x, y, currentStroke);
        }
    }

    onYChanged: {
        if(touchedItem) {
            joint.target = Qt.point(x, y);
        }
        else {
            currentStroke.push(Qt.point(x,y));
            drawingarea.update();
        }
    }

    onPressedChanged: {

        if (pressed) {

            // find out whether we touched an item
            var obj = interactiveitems.childAt(x, y);
            if (obj.objectName === "interactive") {
                touchedItem = obj;
                joint.maxForce = obj.body.getMass() * 500;
                joint.target = Qt.point(x, y);
                joint.bodyB = obj.body;
            }
            else {
                currentStroke = [];
                color = drawingarea.fgColor;
            }

        }
        else { // released
            if(touchedItem) {
                joint.bodyB = null;
                touchedItem = null;
            }
            else {
                drawingarea.finishStroke(currentStroke);
                currentStroke = [];
            }
        }
    }
}

