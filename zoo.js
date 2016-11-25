
var component;

function createCubes() {
    component = Qt.createComponent("cube.qml");
    if (component.status === Component.Ready)
        finishCreation();
    else
        component.statusChanged.connect(finishCreation);

}

function finishCreation() {

    if (component.status === Component.Ready) {
        for (var i=0; i < zoo.nbCubes; i++) {
            var cube = component.createObject(zoo, {"x":Math.random() * (zoo.width - 300) + 150 ,
                                  "y": Math.random() * (zoo.height - 300) + 150,
                                  "rotation": Math.random() * 360});
            if (cube == null) {
                // Error Handling
                console.log("Error creating cube!");
            }
        }
    } else if (component.status === Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
}

