import QtQuick 2.9

Rectangle {
    id: root
    width: parent.width
    height: 42
    color: "#282E33"
    clip: true

    property string image: ""
    property string label: ""
    signal clicked()
    signal stoped()

    Item {
        id: button
        anchors.fill: parent
        clip: true

        Rectangle {
            id: circle
            height: 0
            width: 0
            color: "white"
            opacity: .2

            transform: Translate {
                x: -circle.width / 2
                y: -circle.height / 2
            }

            PropertyAnimation {
                id: circleAnimation
                target: circle
                properties: "width,height,radius"
                from: 0
                to: button.width * 3
                duration: 300
                easing.type: Easing.OutInQuart
                onStopped: {
                    circle.width = 0
                    circle.height = 0
                    leftButton.colored = true
                    stoped()
                }
            }
        }

        LeftPanelButtons {
            id: leftButton
            anchors.fill: parent
            anchors.margins: 2
            image: root.image
            label: root.label
            svg: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: {
                if ( containsMouse && root.color != "#009687" ) {
                    leftButton.colored = true
                    root.color = "#313B43"
                } else if ( !containsMouse && root.color != "#009687" ) {
                    leftButton.colored = false
                    root.color = "#282E33"
                }
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

    function toggle() { leftButton.colored = false }
}
