import QtQuick 2.0

import Box2D 2.0

TouchPoint {

    property var touchedItem: null

    property var activeItems: []

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
            for(var i=0;i<activeItems.length; i++) {
                var item = activeItems[i];

                if (item.isIn(x,y)) {
                    console.log("touching " + item.name)

                    touchedItem=item;
                    break;
                }

            }

            if (touchedItem != null) {
                joint.maxForce = touchedItem.body.getMass() * 500;
                joint.target = Qt.point(x, y);
                joint.bodyB = touchedItem.body;
            }

        }
        else { // released
            joint.bodyB = null;
            touchedItem = null;
        }
    }
}


