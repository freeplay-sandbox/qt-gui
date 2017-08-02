import QtQuick 2.0
import QtMultimedia 5.8
import Box2D 2.0

InteractiveItem {
    id: character

    property double scale: initialScale
    property double initialScale: 1
    property double bbScale: 1.0

    property var stash: parent
    property var food: []
    property double initialLife: 1
    property double life: initialLife
    property bool eating: false
    property double fleeX: 0
    property double fleeY: 0
    property bool alive: false
    property bool isMoved: false
    property double targetLife: 0
    property bool movable: true
    visible: false
    x: -100
    y: -100


    width: 2 * scale * parent.height * sandbox.physicalCubeSize / sandbox.physicalMapWidth
    rotation: 0

    onRotationChanged: rotation = 0
    onXChanged: if(isMoved) testCloseImages()

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

    ParallelAnimation{
        id:flee
        NumberAnimation {target: character; property: "x"; from: x; to: x+fleeX; duration: 500; easing.type: Easing.OutInBounce}
        NumberAnimation {target: character; property: "y";from: y; to: y+fleeY; duration: 500; easing.type: Easing.InOutBounce}
    }
    NumberAnimation {id: lifeChangeAnimation; target: character; property: "life"; from: life; to: targetLife; duration: 800; onRunningChanged: {if(!running) eating = false}}
    NumberAnimation {id: death; target: character; property: "scale"; from: scale; to: 0.1; duration: 1000}


    Lifebar {
        id: lifeSlider
        ratio: life/initialLife
        enabled:false
    }


    Audio {
        id: playCrunch
        source: "res/crunch.mp3"
    }

    function testCloseImages(){
        if(!visible || !alive)
            return
        var list = interactiveitems.getActiveItems()
        for(var i=0 ; i < list.length; i++){
            if(list[i].visible && list[i].life > 0 && testProximity(list[i])){
                if(food.indexOf(list[i].name)>-1){
                    list[i].fleeing()
                    if(!eating && list[i].life>0){// && life < .95*initialLife){
                        list[i].changeLife(-.25)
                        changeLife(0.3)
                    }
                }
                else if(list[i].food.indexOf(name)>-1){
                    fleeing()
                    if (!list[i].eating && life>0){// && list[i].life < .95*list[i].initialLife){
                        changeLife(-.25)
                        list[i].changeLife(.3)
                    }
                }
                else {
                    list[i].fleeing()
                }
            }
        }

        list = interactiveitems.getStaticItems()
        for(var i=0 ; i < list.length; i++){
            if(testProximity(list[i]) && food.indexOf(list[i].type)>-1 && !eating && list[i].life>0){// && life < .95*initialLife){
                list[i].changeLife(-.25)
                changeLife(0.3)
            }
        }

        //checkProximity()
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
            sandbox.livingAnimals++
            visible = true

        }
        else {
            death.start()
        }
    }
    onScaleChanged: {
        if(scale <= 0.1 && visible){
            x=-100
            y=-100
            sandbox.livingAnimals--
            visible = false
            scale = initialScale
            itemDying(name)
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
                var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
            }
            list = interactiveitems.getStaticItems()
            for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x-list[i].x,2)+Math.pow(y-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
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

    function fleeing(){
        var angle = 0
        var distance = 0
        var good = false
        var counter = 0
        while(!good){
            counter++
            good = true
            angle = 2 * Math.PI * Math.random()
            distance = 50 + counter + 200 * Math.random()
            fleeX = distance * Math.cos(angle)
            fleeY = distance * Math.sin(angle)
            if (x+fleeX < 100 || x+fleeX > sandbox.width - 100 || y+fleeY< 100 || y+fleeY>sandbox.height - 100){
                good=false
                continue
            }
            if(counter > 1500){
                break
            }
            var list = interactiveitems.getActiveItems()
            for(var i=0 ; i < list.length; i++){
                var dist = Math.pow(x+fleeX-list[i].x,2)+Math.pow(y+fleeY-list[i].y,2)
                 if(dist<60000 && list[i].name !== name){
                     good = false
                 }
            }
        }

        flee.start()
    }

    function changeLife(value){
        targetLife = life + value
        lifeChangeAnimation.start()
        if(value<0){
            blink("red")
        }
        else{
            blink("green")
            eating=true
        }
    }

    function blink(color){
            lifeSlider.blinkColor = color
            lifeSlider.animation.start()
    }

    function initiate(){
        visible = true
        relocate()
        alive = true
        life = initialLife
        scale = initialScale
    }

    onEatingChanged:{
        if (eating){
            var i = Math.floor(Math.random() * 10) + 1
            playCrunch.source = "/res/crunch"+i+".mp3"
            playCrunch.play()
            animalEating(name)
        }
    }
 }
