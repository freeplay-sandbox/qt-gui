import QtQuick 2.0

Item {

    id: arrow

    property var origin: null
    property var end: null
    property color color: "red"
    z:10
    visible: true
    anchors.fill: parent

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property var path: []
        property double angle: 0

        property int arrowHeadLength: 40 //px

        onPaint: {
            var i = 0;
            var p1 = {x: origin.x + origin.width/2,y:origin.y+origin.height/2}
            var p2 = {x: end.x,y:end.y}
            if(typeof end.name !== 'undefined')
                p2 = {x: end.x + end.width/2,y:end.y+end.height/2}
            else

            angle = -Math.atan2(p2.x-p1.x,p2.y-p1.y)+Math.PI/2
            p2.x -=arrowHeadLength*Math.cos(angle);
            p2.y -=arrowHeadLength*Math.sin(angle);

            var ctx = canvas.getContext('2d');

            ctx.reset();

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = arrow.color;
            ctx.fillStyle = arrow.color;


            ctx.beginPath();

            ctx.moveTo(p1.x, p1.y);

            ctx.lineTo(p2.x, p2.y);

            ctx.stroke();

            ctx.beginPath();
            ctx.translate(p2.x, p2.y);
            ctx.rotate(angle);
            ctx.lineTo(0, 20);
            ctx.lineTo(arrowHeadLength, 0);
            ctx.lineTo(0, - 20);
            ctx.closePath();
            ctx.fill();
        }
    }
    function paint(){
        canvas.requestPaint()
    }
}
