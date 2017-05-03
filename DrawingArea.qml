import QtQuick 2.2

import Ros 1.0

Item {

    id: drawingarea

    property double pixelscale: 1.0 // how many meters does 1 pixel represent?

    property color bgColor: "transparent"
    property string bgImage: "res/map.svg"
    property int lineWidth: 50

    property color fgColor: colorpicker.paintbrushColor

    property var strokes: []

    property bool drawEnabled: false

    Rectangle {
        id: colorpicker

        opacity: drawingarea.drawEnabled ? 1 : 0
        x:10
        anchors.verticalCenter: parent.verticalCenter

        property int padding: 10
        width: childrenRect.width + padding
        height: childrenRect.height + padding
        z:1

        border.width: 5
        border.color: "black"

        color: "transparent"

        Behavior on opacity {
            NumberAnimation {
                duration:300
            }
        }

        property alias paintbrushColor: colorGrid.color

        Grid {
            x: 5
            y: 5
            id: colorGrid

            property int colorPickerCols: 2

            property var colors: ["#fce94f",
                "#fcaf3e",
                "#73d216",
                "#2e3436",
                "#3465a4",
                "#ad7fa8",
                "#ef2929",
                "#eeeeec"]

            property color color: {
                for (var i = 0; i < children.length; i++)
                    if(children[i].selected)
                        return children[i].color;

                return "transparent";
            }

            columns: colorPickerCols

            Component.onCompleted: createColors();


            function uniqueSelect(sampler) {
                for (var i = 0; i < children.length; i++) {
                    children[i].selected = false;
                }
                sampler.selected=true;
            }

            function createColors() {

                var sampler;
                for (var i = 0; i < colors.length; i++) {
                    var component = Qt.createComponent("ColorSample.qml");
                    sampler = component.createObject(colorGrid, {"color": colors[i]});

                    sampler.tapped.connect(uniqueSelect);
                }
            }

        }

        Image {
            id: eraserbutton
            anchors.top: colorGrid.bottom
            anchors.horizontalCenter: colorGrid.horizontalCenter

            source: "res/eraser.svg"

            width: 60
            height: width
            rotation: -90

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    for (var i = 0; i < colorGrid.children.length; i++) {
                        colorGrid.children[i].selected = false;
                    }


                }
            }
        }

        Image {
            id: okbutton
            anchors.top: eraserbutton.bottom
            anchors.horizontalCenter: colorGrid.horizontalCenter

            source: "res/ok.svg"

            width: 60
            height: width
            rotation: -90

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    interactiveitems.opacity = 1;
                    drawModeButton.opacity = 1;
                    drawingarea.drawEnabled = false;

                }
            }
        }
    }

    MultiPointTouchArea {
        id:touchs
        enabled: drawingarea.drawEnabled
        anchors.fill: parent
    touchPoints: [
        TouchPoint {
            id: touch1
            property var currentStroke: []
            property color color: "black"
            onYChanged: drawingarea.addPoint(x, y, currentStroke)
            onPressedChanged: {
                if (pressed) {
                    color = drawingarea.fgColor;
                }
                if (!pressed) {
                    drawingarea.finishStroke(currentStroke);
                    currentStroke = [];
                }
            }
        },
        TouchPoint {
            id: touch2
            property var currentStroke: []
            property color color: "black"
            onYChanged: drawingarea.addPoint(x, y, currentStroke)
            onPressedChanged: {
                if (pressed) {
                    color = drawingarea.fgColor;
                }
                if (!pressed) {
                    drawingarea.finishStroke(currentStroke);
                    currentStroke = [];
                }
            }

        },
        TouchPoint {
            id: touch3
            property var currentStroke: []
            property color color: "black"
            onYChanged: drawingarea.addPoint(x, y, currentStroke)
            onPressedChanged: {
                if (pressed) {
                    color = drawingarea.fgColor;
                }
                if (!pressed) {
                    drawingarea.finishStroke(currentStroke);
                    currentStroke = [];
                }
            }

        },
        TouchPoint {
            id: touch4
            property var currentStroke: []
            property color color: "black"
            onYChanged: drawingarea.addPoint(x, y, currentStroke)
            onPressedChanged: {
                if (pressed) {
                    color = drawingarea.fgColor;
                }
                if (!pressed) {
                    drawingarea.finishStroke(currentStroke);
                    currentStroke = [];
                }
            }

        }
    ]

    }

    Canvas {
        id: canvas
        antialiasing: true
        opacity: 1
        property real alpha: 1

        property var lastCanvasData: null
        property var bgCanvasData: null

        anchors.fill: parent

        function storeCurrentDrawing() {
            var ctx = canvas.getContext('2d');
            lastCanvasData = ctx.getImageData(0,0,width, height);
        }

        ImagePublisher {
            id: drawingPublisher
            target: parent
            topic: "/sandbox/image"
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
                    ctx.drawImage(bgCanvasData,0,0);
                    ctx.drawImage(lastCanvasData,0,0);
                }
            }

            drawingPublisher.publish();
        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            };
        }

        Component.onCompleted: loadImage(drawingarea.bgImage);

    }

    function addPoint(x, y, stroke) {
        stroke.push(Qt.point(x,y));
        canvas.requestPaint();
    }

    function finishStroke(stroke) {
        canvas.storeCurrentDrawing();
        stroke = [];
    }
}
