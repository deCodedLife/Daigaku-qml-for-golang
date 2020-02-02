import QtQuick 2.0

Rectangle {
    id: itemTag
    width: itemTag.width
    height: itemTag.height
    color: "#282E33"
    clip: true

    property string text: ""

    signal clicked()
    signal stoped()

    Rectangle {
        id: circle
        color: "white"
        opacity: .2
        width: 0
        height: 0

        transform: Translate {
            x: -circle.width / 2
            y: -circle.height / 2
        }

        PropertyAnimation {
            id: circleAnimation
            properties: "width,height,radius"
            target: circle
            from: 0
            to: itemTag.width * 3
            duration: 250
            onStopped: {
                circle.width = 0
                circle.height = 0
                itemTag.stoped()
            }
        }
    }

    Text {
        id: txt
        text: itemTag.text
        font.pixelSize: 16
        color: "white"
        smooth: true
        anchors.centerIn: parent
        font.letterSpacing: 1.5
    }

    MouseArea {
        id: mouse
        width: itemTag.width
        height: itemTag.height
        hoverEnabled: true
        onHoveredChanged: {
            if ( mouse.containsMouse && itemTag.color != "#009687" ) itemTag.color = "#353C43"
            else if ( !mouse.containsMouse && itemTag.color != "#009687" ) itemTag.color = "#282E33"
        }
        onClicked: {
            itemTag.clicked()
            circleAnimation.stop()
        }
        onPressed: {
            circle.x = mouseX
            circle.y = mouseY
            circleAnimation.start()
        }
        onReleased: circleAnimation.stop()
        onPositionChanged: circleAnimation.stop()
    }
}
