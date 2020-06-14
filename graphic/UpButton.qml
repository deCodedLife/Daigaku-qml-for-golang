import QtQuick 2.9
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0

Item {
    id: root
    width: parent.height
    height: parent.height

    property bool closed: false
    property bool windowMaximized: true
    property string image: ""
    property string subImage: ""

    signal clicked()

    onWindowMaximizedChanged: {
        if ( windowMaximized ) {
            img.visible = true
            color.source = img
            sub.visible = false
        } else {
            img.visible = false
            color.source = sub
            sub.visible = true
        }
    }

    Rectangle {
        id: item
        anchors.fill: parent
        color: "#3A4047"

        Image {
            id: img
            width: 17
            height: 17
            mipmap: true
            anchors.centerIn: parent
            sourceSize: Qt.size( 17, 17 )
            source: image

        }

        Image {
            id: sub
            width: 17
            height: 17
            mipmap: true
            anchors.centerIn: parent
            sourceSize: Qt.size( 17, 17 )
            source: subImage
            visible: false
        }

        ColorOverlay {
            id: color
            anchors.fill: img
            source: img
            color:  "#808080"
            antialiasing: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onHoveredChanged: {
                if ( containsMouse ) {
                    item.color = closed ? "#E81123" : "#282E33"
                    color.color = "white"
                } else {
                    item.color = "#3A4047"
                    color.color = "#808080"
                }
            }
            onClicked: root.clicked()
        }
    }

}
