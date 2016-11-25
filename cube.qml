import QtQuick 2.0

Item {
    id:cube
    width: 100
    height: 100
    Image {
        id: cube_texture
        anchors.fill: parent
        source: "res/cube.svg"

    }
    PinchArea {
        anchors.fill: parent
        pinch.target: parent
        //pinch.minimumRotation: -180
        //pinch.maximumRotation: 180
        //pinch.minimumScale: 1
        //pinch.maximumScale: 1
        pinch.dragAxis: Pinch.XAndYAxis
    }

}
