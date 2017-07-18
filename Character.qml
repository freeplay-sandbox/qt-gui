import QtQuick 2.0
import Box2D 2.0

InteractiveItem {
    id: character

    property double scale: 1.0
    property double bbScale: 1.0

    property var stash: parent
    property var food: []
    property double initialLife: 1
    property double life: initialLife
    property bool alive: false
    property bool isMoved: false
    visible: false
    x: -100
    y: -100


    width: 2 * scale * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    rotation: 0

    onRotationChanged: rotation = 0

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
            if(testProximity(list[i])){
                if(food.indexOf(list[i].name)>-1){
                    list[i].life -= 0.25
                    list[i].relocate()
                    life += 0.3
                }
                if(list[i].food.indexOf(name)>-1){
                    life -= 0.25
                    relocate()
                    list[i].life += .3
                }
            }
        }

        list = interactiveitems.getStaticItems()
        for(var i=0 ; i < list.length; i++){
            if(testProximity(list[i]) && food.indexOf(list[i].name)>-1){
                list[i].relocate()
                life += 0.3
            }
        }

        checkProximity()
    }
    onLifeChanged: {
        if(life>initialLife)
            life = initialLife
        if(life<=0){
            life = 0
            alive = false
        }
    }
    onAliveChanged: {
        if(alive){
            relocate()
            sandbox.livingAnimals++
            visible = true
        }
        else {
            x=-100
            y=-100
            sandbox.livingAnimals--
            visible = false
        }
    }

    function relocate(){
        if(!visible)
            return
        var good = false
        while(!good){
            good = true
            x = drawingarea.width * (.15 + 0.7 * Math.random())
            y = drawingarea.height * (.15 + 0.7 * Math.random())
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
                if(testProximity(list[i]))
                    good = false
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
                if(testProximity(list[i]))
                    good = false
            }
        }
    }
    function  checkProximity(){
        if(isMoved || !alive)
            return
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
            if(testProximity(list[i])){
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

    function testProximity(item){
        var dist = Math.pow(x-item.x,2)+Math.pow(y-item.y,2)
        if(dist<10000 * Math.pow(Math.max(item.scale,scale),2) && item.name !== name)
            return true
        else
            return false
    }
}
