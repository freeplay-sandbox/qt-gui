import QtQuick 2.0
import Box2D 2.0

InteractiveItem {
    id: character

    visible: true
    property double scale: 1.0
    property double bbScale: 1.0

    property var stash: parent
    property var food: []
    property double life: 1
    property bool isMoved: false

    x: stash.x + 10 + Math.random() * 0.4 * stash.width
    y: stash.y + 10 + Math.random() * 0.9 * stash.height

    width: scale * 4 * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    rotation: Math.random() * 360

    property double bbRadius: bbScale * character.width/2
    property point bbOrigin: Qt.point(character.width/2, character.height/2)

    property alias friction: bbpoly.friction
    property alias restitution: bbpoly.restitution
    property alias density: bbpoly.density
    property alias collidesWith: bbpoly.collidesWith

    boundingbox: Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(bbOrigin.x + bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y + bbRadius),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y + 0.7 * bbRadius),
                    Qt.point(bbOrigin.x - bbRadius, bbOrigin.y),
                    Qt.point(bbOrigin.x - 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius),
                    Qt.point(bbOrigin.x, bbOrigin.y - bbRadius),
                    Qt.point(bbOrigin.x + 0.7 * bbRadius, bbOrigin.y - 0.7 * bbRadius)
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

    function testCloseImages(){
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
           var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
            if(dist<8000){
                if(food.indexOf(list[i].name)>-1){
                    list[i].relocate()
                    life += 0.3
                }
                if(list[i].food.indexOf(name)>-1){
                    relocate()
                    list[i].life += .3
                }
            }
        }

        list = interactiveitems.getStaticItems()
        for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<8000){
                    if(food.indexOf(list[i].name)>-1){
                        list[i].relocate()
                        life += 0.3
                    }
                }
            }

        checkProximity()
    }
    onLifeChanged: {
        if(life>1)
            life = 1
        if(life<0)
            life = 0
    }

    function relocate(){
        var good = false
        while(!good){
            good = true
            x = drawingarea.width * (.15 + 0.7 * Math.random())
            y = drawingarea.height * (.15 + 0.7 * Math.random())
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<20000 && list[i].name !== name){
                    good = false
                }
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
                console.log(list[i].name)
               var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                if(dist<20000 && list[i].name !== name){
                    good = false
                }
            }
        }
    }
    function  checkProximity(){
        if(isMoved)
            return
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
           var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
            if(dist<10000 && list[i].name !== name){
                console.log(x+" "+list[i].x)
                x += 20/(x-list[i].x)
                y += 20/(y-list[i].y)
                startProximityTimer()
                list[i].startProximityTimer()
            }
        }
    }
    Timer {
        id: proximityTimer
        interval: 10; running: false; repeat: false
        onTriggered: {
            checkProximity()
        }
    }
    function startProximityTimer(){
        proximityTimer.running = true
    }
}
