import QtQuick 2.2

import Ros 1.0

Item {

    id: drawingarea

    property double pixelscale: 1.0 // how many meters does 1 pixel represent?

    property string bgImage
    property int lineWidth: 50

    property color fgColor

    property bool drawEnabled: true

    property var touchs


    Image {
        id: canvas
        antialiasing: true
        opacity: 1
        property real alpha: 1

        source:"res/map.svg";

        property var lastCanvasData
        property var bgCanvasData

        anchors.fill: parent

        ImagePublisher {
            id: drawingPublisher
            target: parent
            topic: "/sandtray/background/image"
            latched: true
            frame: "sandtray"
            pixelscale: drawingarea.pixelscale

        }

        Component.onCompleted: {


        }


        Timer {
            interval: 3000; running: true; repeat: false
            onTriggered: {
                drawingPublisher.publish();
            }
        }
        onHeightChanged: {
            drawingPublisher.publish();
        }
        onWidthChanged: {
            drawingPublisher.publish();
        }
    }
}
