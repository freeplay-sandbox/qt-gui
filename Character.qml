import QtQuick 2.0
import Box2D 2.0

Cube {
    id: character


    property double scale: 1.0
    property double bbScale: 1.0

    x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
    y: 0.1 * parent.height + Math.random() * 0.8 * parent.height

    width: scale * 2 * parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
    rotation: -30 + Math.random() * 60


    boundingbox:  Circle {
        id: circleShape
        radius: bbScale * character.width/2
        x: character.width/2 - radius
        y: character.height/2 - radius
        density: 1
        friction: 1
        restitution: 0.1
    }


}
