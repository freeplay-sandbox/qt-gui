import QtQuick 2.0


Rectangle {
    id: colorpicker


    property int padding: 10
    width: childrenRect.width + padding
    height: childrenRect.height + padding

    border.width: 5
    border.color: "black"

    color: "#33FFFFFF"
    radius: 10

    Behavior on opacity {
        NumberAnimation {
            duration:300
        }
    }

    property alias paintbrushColor: colorGrid.color

    Image {
        anchors.horizontalCenter: colorGrid.horizontalCenter
        id: eraserbutton

        property bool selected: false

        source: selected ? "res/eraser_selected.svg" : "res/eraser.svg"

        width: 80
        height: width
        rotation: -90

        MouseArea {
            anchors.fill: parent
            onClicked: {
                eraserbutton.selected = true;
                for (var i = 0; i < colorGrid.children.length; i++) {
                    colorGrid.children[i].selected = false;
                }


            }
        }
    }

    Grid {
        anchors.top: eraserbutton.bottom

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
            eraserbutton.selected=false;
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

    /*
    Image {
        id: okbutton
        anchors.top: colorGrid.bottom
        anchors.horizontalCenter: colorGrid.horizontalCenter

        source: "res/ok.svg"

        width: 80
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
    */
}


