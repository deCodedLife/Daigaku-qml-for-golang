import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root
    width: root.width
    height: root.height
    visible: false
    opacity: 0

    property string title: ""
    property string text: ""
    property string type: ""
    property bool question: true

    signal okClicked()

    Rectangle {
        id: back
        width: root.width
        height: root.height
        color: Qt.rgba(0,0,0,0.4)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onClicked: showAnimation.running = true
        }

        z: 10
    }

    Rectangle {
        id: element
        color: "#18191D"
        width: 400
        height: text.paintedHeight + 48 > 200 ? text.paintedHeight + 48 : 200
        layer.enabled: true
        layer.effect: DropShadow {
            Layout.alignment: Layout.Center
            horizontalOffset: 3
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: "#80000000"
        }
        radius: 4
        anchors.centerIn: parent

        Text {
            id: titleText
            text: root.title
            font.pointSize: 14
            smooth: true
            color: type == "info" ? "white" : type == "warn" ? "#FEBB30" : "#9C3F5E"
            x: 10
            y: 8
            font.letterSpacing: 1.5
        }

        Flickable {
            id: flickable
            width: element.width - 20
            height: text.paintedHeight
            flickableDirection: Flickable.VerticalFlick
            contentHeight: flickable.height
            y: 32
            x: 10

            TextArea.flickable: TextArea {
                id: text
                font.pixelSize: 16
                color: "white"
                wrapMode: Text.Wrap
                renderType: TextArea.NativeRendering
                text: root.text
                font.letterSpacing: 1.5
                smooth: true
                background: Rectangle { anchors.fill: parent; color: "#18191D" }

                onTextChanged: resize()

                function resize() {
                    element.height = text.paintedHeight + row.height + titleText.paintedHeight > 200 ? text.paintedHeight + row.height + titleText.paintedHeight + 16 : 200
                    element.height = text.paintedHeight + row.height > root.height - root.height / 4 ? root.height - 10 : element.height
                    flickable.height = text.paintedHeight > element.height ? element.height - row.height - titleText.paintedHeight - 32 : text.paintedHeight + text.font.pointSize * 2
                    flickable.contentHeight = text.paintedHeight + text.font.pointSize * 2
                    text.update()
                }
            }

            ScrollBar.vertical: ScrollBar{
                id: scroll
                parent: flickable.parent
                policy: ScrollBar.AsNeeded
            }
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: {}
        }
        RowLayout {
            id: row
            width: parent.width - 20
            height: 48
            anchors.bottom: parent.bottom
            anchors.margins: 10
            spacing: 10
            x: 10
            Layout.alignment: Qt.AlignRight
            Rectangle { Layout.fillHeight: true; Layout.fillWidth: true; color: Qt.rgba(0,0,0,0) }
            DButton {
                Layout.alignment: Qt.AlignRight
                text: " Отмена "
                background: "#18191D"
                accent: "#009687"
                onClicked: showAnimation.running = true
                color: "white"
                visible: question == true ? true : false
            }
            DButton {
                Layout.alignment: Qt.AlignRight
                text: " Ок "
                background: "#18191D"
                accent: "#009687"
                onClicked: {
                    if ( !question ) showAnimation.running = true
                    okClicked()
                }
                color: "white"
            }
        }
        z: 12
    }

    NumberAnimation on opacity {
        id: showAnimation
        to: root.opacity == 1 ? 0 : 1
        duration: 200
        easing.type: Easing.InOutQuart
        running: false
        onStopped: {
            type = "info"
            if ( root.opacity == 0 ) {
                back.visible = false
                root.visible = false
            }
        }
    }

    onWidthChanged: text.resize()
    onHeightChanged: text.resize()

    function show () {
        root.visible = true;
        back.visible = root.visible
        showAnimation.running = true
    }
}
