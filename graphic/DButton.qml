import QtQuick 2.9

Item {
    id: root
    implicitWidth: txt.contentWidth + pointSize
    implicitHeight: txt.contentHeight + pointSize
    clip: true

    property string text: ""
    property int pointSize: 14
    property string accent: ""
    property string color: ""
    property string background: ""

    signal clicked()

    Rectangle {
        id: circle
        width: 0
        height: 0
        color: "white"
        opacity: .2
        smooth: true

        transform: Translate {
            x: -circle.width / 2
            y: -circle.height / 2
        }

        PropertyAnimation {
            id: circleAnimation
            from: 0
            to: root.width * 3
            target: circle
            properties: "width,height,radius"
            onStopped: {
                circle.width = 0
                circle.height = 0
            }
        }
    }

    Rectangle {
        id: item
        anchors.fill: parent
        color: background
        radius: 4
        smooth: true

        Text {
            id: txt
            text: root.text
            color: root.color
            font.pointSize: pointSize
            smooth: true
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.letterSpacing: 1.5
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onHoveredChanged: {
            if ( containsMouse ) item.color = accent
            else item.color = background
        }
        onClicked: {
            circleAnimation.stop()
            root.clicked()
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
