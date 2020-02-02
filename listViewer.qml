import QtQuick 2.0

Rectangle {
    id: list
    radius: 4
    width: 0
    height: 0
    color: "#18191D"
    opacity: 0
    x: xpos

    property var model: []
    property var func: list.func
    property int xpos: list.xpos
    property var extended: false

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: {
            if ( !containsMouse ) closeTimer.running = true
            else closeTimer.running = false
        }
        propagateComposedEvents: true
    }

    Column {
        width: parent.width
        height: parent.height - 10
        y: 5

        Repeater {
            id: repeater
            model: list.model
            visible: false

            delegate: Item {
                id: item
                width: parent.width
                height: 21

                Rectangle {
                    id: white
                    anchors.fill: parent
                    color: "white"
                    opacity: 0.2
                    visible: false
                }

                Rectangle {
                    id: circle
                    width: 0
                    height: 0
                    color: "white"
                    opacity: 0.4

                    transform: Translate {
                        x: -circle.width / 2
                        y: -circle.height / 2
                    }

                    PropertyAnimation {
                        id: circleAnimation
                        target: circle
                        properties: "width,height,radius"
                        from: 0
                        to: item.width * 3
                        onStopped: {
                            circle.height = 0
                            circle.width = 0
                        }
                    }
                }

                Text {
                    id: txt
                    text: modelData
                    font.pointSize: 12
                    color: "white"
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font.letterSpacing: 1.5
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if ( containsMouse ) {
                            extended = true
                            white.visible = true
                        } else {
                            extended = false
                            white.visible = false
                            if ( !mouseArea.containsMouse && extended == false ) duration.running = true
                        }
                    }

                    onClicked: {
                        circleAnimation.stop()
                        func.index = index
                        func.running = true
                        closeTimer.running = true
                    }
                    onPressed: {
                        circle.x = mouseX
                        circle.y = mouseY
                    }
                    onReleased: circleAnimation.stop()
                    onPositionChanged: circleAnimation.stop()
                    propagateComposedEvents: true
                }
            }
        }
    }

    NumberAnimation on width {
        to: 170
        duration: 100
        easing.type: Easing.InOutQuart
    }

    NumberAnimation on x {
        to: xpos - 170
        duration: 100
        easing.type: Easing.InOutQuart
    }

    NumberAnimation on height {
        to: model.length * 21 + 10
        duration: 100
        easing.type: Easing.InOutQuart
    }

    NumberAnimation on opacity {
        to: 1
        duration: 100
        easing.type: Easing.InOutQuart
        onStopped: {
            repeater.width = list.width
            repeater.height = list.height
            repeater.visible = true
        }
    }

    NumberAnimation on opacity {
        id: hideAnimation
        to: 0
        easing.type: Easing.InOutQuart
        running: false
        duration: 100
        onStopped: {
            list.model = []
            list.visible = false
        }
    }

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: hideAnimation.running = true
    }

    Timer {
        id: duration
        interval: 50
        onTriggered: {
            if ( !mouseArea.containsMouse && extended == false )
                closeTimer.running = true
        }
    }
}
