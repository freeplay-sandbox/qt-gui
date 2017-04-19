import QtQuick 2.0

import Box2D 2.0

TouchPoint {

    property var touchedItem: null

    property MouseJoint joint: MouseJoint {
    bodyA: anchor
    dampingRatio: 1
    maxForce: 1
    }

    onXChanged: {
        joint.target = Qt.point(x, y);
    }
    onYChanged: {
        joint.target = Qt.point(x, y);
    }

    onPressedChanged: {

        if (pressed) {

            // find out whether we touched an item
            var obj = interactiveitems.childAt(x, y);
            if (obj.objectName === "interactive") {
                joint.maxForce = obj.body.getMass() * 500;
                joint.target = Qt.point(x, y);
                joint.bodyB = obj.body;
            }

        }
        else { // released
            joint.bodyB = null;
            touchedItem = null;
        }
    }
}


