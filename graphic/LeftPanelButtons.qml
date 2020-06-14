import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
Item {
    id: root
    anchors.fill: parent

    property string image: ""
    property string label: ""
    property bool colored: false
    property bool svg: false

    Material.theme: Material.Dark
    Material.accent: "#009687"

    Image {
        id: img
        source: image
        width: 32
        height: 32
        sourceSize: Qt.size( 32, 32 )
        y: parent.height / 2 - 16
        x: 32 / 2
        antialiasing: true

        NumberAnimation on x {
            id: imgAnimation
            to: img.x == 32 / 2 ? 0 : 32 / 2
            duration: 100
            easing.type: Easing.InOutQuart
            running: false
        }

        ColorOverlay {
            anchors.fill: img
            source: img
            color: colored == true ? "white" : "#808080"
            antialiasing: true
            visible: svg == true ? true : false
        }
    }
    Text {
        id: text
        x: 64
        font.pixelSize: 16
        y: parent.height / 2 - text.contentHeight / 2
        color: "white"
        smooth: true
        text: label
        font.letterSpacing: 1.5
        Component.onCompleted: {
            if ( image == "" ) {
                text.x = root.width / 2 - text.contentWidth / 2
                text.y = root.height / 2 - text.contentHeight / 2
            }
        }
    }

    function color() {
        if ( element.color == "#313B43" ) element.color = "#282E33"
        else element.color = "#313B43"
    }
    onWidthChanged: {
        if ( root.width == 196 ) imgAnimation.running = true
        else imgAnimation.running = true
    }
}
