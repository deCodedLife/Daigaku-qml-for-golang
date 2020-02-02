import QtQuick 2.9
import QtGraphicalEffects 1.0

Item {
    id: root
    width: root.width
    height: 42

    property string image: root.image
    property int indexNum: index
    property bool updater: false
    property var model: []
    property var func:  root.func
    signal clicked()

    Rectangle {
        anchors.fill: parent
        color: "#282E33"
        radius: 4
        clip: true

        Image {
            id: img
            width: 48
            asynchronous: true
            height: 48
            source: image
            sourceSize: Qt.size( 64, 64 )
            y: parent.height / 2 - img.height / 2
            anchors.left: parent.left
            anchors.leftMargin: 5
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: mask }
        }

        Rectangle {
            id: mask
            width: 48
            height: 48
            radius: 5
            visible: false
            antialiasing: true
        }

        Text {
            id: curator
            font.pixelSize: 14
            x: 68
            y: parent.height / 4 - curator.contentHeight / 2
            text: modelData["operator"]
            color: "white"
            renderType: Text.NativeRendering
            font.letterSpacing: 1.5
        }

        Text {
            id: txt
            width: updater ? parent.width - 32 - 68 : parent.width - 68
            height: img.height / 2 - txt.font.pointSize / 2
            text: modelData["tag"] + ": " + modelData["task"]
            x: 68
            y: parent.height - parent.height / 2
            font.pixelSize: 16
            color: "white"
            wrapMode: Text.WordWrap
            font.letterSpacing: 1.5
            renderType: Text.NativeRendering
            clip: true
        }

        Image {
            id: svg
            source: "qrc:/images/more.svg"
            width: 32
            height: 32
            sourceSize: Qt.size( 64, 64 )
            y: parent.height / 2 - 16
            anchors.right: parent.right
            anchors.rightMargin: 5
            asynchronous: true
            visible: updater

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if ( containsMouse )
                        colorOverlay.color = "white"
                    else
                        colorOverlay.color = "#808080"
                }
                onClicked: {
                    if ( root.model.length != 0 ) {
                        let component = Qt.createComponent("listViewer.qml")
                        let meta = {
                            "model" : root.model,
                            "y"     : svg.y + (index * root.height ),
                            "xpos"  : svg.x + svg.width,
                            "func"  : func,
                            "z"     : 1
                        }
                        component.createObject( root.parent, meta )
                    } else root.func.running = true
                }
            }

            ColorOverlay {
                id: colorOverlay
                anchors.fill: svg
                source: svg
                color: "#808080"
                antialiasing: true
            }
        }
    }

    MouseArea {
        width: parent.width - 38
        height: parent.height
        onClicked: root.clicked()
    }
}
