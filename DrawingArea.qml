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


    Canvas {
        id: canvas
        antialiasing: true
        opacity: 1
        property real alpha: 1

        property var lastCanvasData
        property var bgCanvasData

        anchors.fill: parent

        function storeCurrentDrawing() {
            var ctx = canvas.getContext('2d');
            lastCanvasData = ctx.getImageData(0,0,width, height);
        }

        ImagePublisher {
            id: drawingPublisher
            target: parent
            topic: "/sandtray/background/image"
            latched: true
            frame: "sandtray"
            pixelscale: drawingarea.pixelscale

        }

        onPaint: {

            var strokeIdx = 0;
            var i = 0;
            var ctx = canvas.getContext('2d');

            //ctx.reset();

            ctx.globalAlpha = canvas.alpha;

            // storing the background image -- needed to repaint behind the rubber
            if (!bgCanvasData && isImageLoaded(drawingarea.bgImage)) {
                bgCanvasData = ctx.createImageData(drawingarea.bgImage);
                ctx.drawImage(bgCanvasData,0,0);
            }

            //if(bgCanvasData) ctx.drawImage(bgCanvasData,0,0);

            if (lastCanvasData) ctx.drawImage(lastCanvasData,0,0);

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            var currentStrokes = [];
            for (var i = 0; i < touchs.touchPoints.length; i++) {

                if(touchs.touchPoints[i].currentStroke.length !== 0) {
                    currentStrokes.push({color: touchs.touchPoints[i].color.toString(),
                                         points: touchs.touchPoints[i].currentStroke,
                                         width: drawingarea.lineWidth
                                });
                }
            }

            for (strokeIdx = 0; strokeIdx < currentStrokes.length; strokeIdx++) {
                var points = currentStrokes[strokeIdx].points;
                var width = currentStrokes[strokeIdx].width;

                ctx.lineWidth = width;

                ctx.beginPath();

                var prevCompositeMode = ctx.globalCompositeOperation;

                // are we in 'eraser' mode (ie, 'transparent' color)?
                // if yes, change the composite mode to erase the canvas
                // instead of painting over
                if(currentStrokes[strokeIdx].color === "#00000000") {
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.strokeStyle = "black";
                }
                else {
                    ctx.strokeStyle = currentStrokes[strokeIdx].color;
                }

                var p1 = points[0];
                var p2 = points[1];

                ctx.moveTo(p1.x, p1.y);

                for (i = 1; i < points.length; i++)
                {
                    // we pick the point between pi+1 & pi+2 as the
                    // end point and p1 as our control point
                    var midPoint = midPointBtw(p1, p2);
                    ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y);
                    p1 = points[i];
                    p2 = points[i+1];

                }
                ctx.lineTo(p1.x, p1.y);

                ctx.stroke();

                // if in eraser mode,
                // 1- restore the composite mode ('paint over')
                // 2- redraw the background
                // 3- overlay the drawings
                if(currentStrokes[strokeIdx].color === "#00000000") {
                    ctx.globalCompositeOperation = prevCompositeMode;
                    lastCanvasData = ctx.getImageData(0,0,canvas.width, canvas.height);
                    gc(); // explicitely call the garbage collector, otherwise, memory leaks
                    ctx.drawImage(bgCanvasData,0,0);
                    ctx.drawImage(lastCanvasData,0,0);
                }
            }

        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            };
        }

        Component.onCompleted: loadImage(drawingarea.bgImage);

        RosSignal {
            topic: "signal_sandtray_clear_drawing"

            onTriggered: {
                canvas.lastCanvasData = null;
                var ctx = canvas.getContext('2d');
                ctx.drawImage(canvas.bgCanvasData,0,0);
                canvas.requestPaint();
                drawingPublisher.publish();
            }
        }

        Timer {
            interval: 3000; running: true; repeat: false
            onTriggered: {
                console.log("Initial publishing of the background");
                drawingPublisher.publish();
            }
        }

    }

    function update() {
        canvas.requestPaint();
    }

    function finishStroke(stroke) {
        drawingPublisher.publish();
        canvas.storeCurrentDrawing();
        stroke = [];
    }
}
