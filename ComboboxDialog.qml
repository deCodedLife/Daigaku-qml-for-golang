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
    property string selectedGroup: ""
    property int selectedIndex: 0
    property var model: []

    signal okClicked()

    Rectangle {
        id: back
        width: root.width
        height: root.height
        color: Qt.rgba(0,0,0,0.2)

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
        height: 200
        radius: 4
        layer.enabled: true
        layer.effect: DropShadow {
            Layout.alignment: Layout.Center
            horizontalOffset: 3
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: "#80000000"
        }
        anchors.centerIn: parent

        Text {
            id: titleText
            text: root.title
            font.pointSize: 16
            smooth: true
            color: "white"
            x: 10
            y: 8
            font.letterSpacing: 1.5
            Component.onCompleted: {
                switch( root.type ) {
                    case "info" : titleText.color = "white"; break
                    case "warning" : titleText.color = "#FEBB30"; break
                    case "error" : titleText.color = "#9C3F5E"; break
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: {}
        }

        ComboBox {
            id: combobox
            width: parent.width - 10
            height: 42
            model: root.model
            x: 5
            y: parent.height / 2 - 21
            editable: true
            font.letterSpacing: 1.5
        }

        RowLayout {
            id: row
            width: parent.width - 20
            height: 48
            anchors.bottom: parent.bottom
            anchors.margins: 5
            spacing: 10
            x: 10
            Layout.alignment: Qt.AlignRight
            Rectangle { Layout.fillHeight: true; Layout.fillWidth: true; color: Qt.rgba(0,0,0,0) }
            DButton {
                Layout.alignment: Qt.AlignRight
                text: "Отмена"
                background: "#18191D"
                accent: "#009687"
                onClicked: showAnimation.running = true
                color: "white"
                visible: true
            }
            DButton {
                Layout.alignment: Qt.AlignRight
                text: "Ок"
                background: "#18191D"
                accent: "#009687"
                onClicked: {
                    root.selectedIndex = combobox.currentIndex
                    root.selectedGroup = combobox.currentText
                    showAnimation.running = true
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
        duration: 100
        easing.type: Easing.InOutQuart
        running: false
        onStopped: {
            if ( root.opacity == 0 ) {
                back.visible = false
                root.visible = false
            }
        }
    }

    function show () {
        root.visible = true;
        back.visible = root.visible
        showAnimation.running = true
    }

    function hide() {
        root.visible = false;
        back.visible = false;
    }
}
