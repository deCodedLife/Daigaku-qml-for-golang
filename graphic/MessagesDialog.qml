import QtQuick 2.0
import QtQuick.Controls 2.5
import "qrc:/sources/core.js" as JsLib

Item {
    id: root

    width: parent.width
    height: parent.height
    anchors.margins: 10
    //clip: true

    property var func: root.func
    property bool updater: false
    property var model: ["Изменить", "Удалить"]

    Item {
        anchors.fill: parent

        Rectangle {
            id: message
            color: "#2A2F33"
            radius: 5
            width: parent.width
            height: parent.height
            antialiasing: true

            Rectangle {
                height: parent.radius
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color: parent.color
            }

            Item {

                id: item
                anchors.fill: parent
                anchors.margins: 5

                Text {
                    id: txt
                    text: modelData["message"]
                    font.pointSize: 11.5
                    color: "white"
                    smooth: true
                    font.family: "Segoe UI Black"
                    wrapMode: Text.Wrap
                    renderType: Text.NativeRendering
                    Component.onCompleted: resize()
                    font.letterSpacing: 1.5

                    function resize() {
                        message.width = txt.paintedWidth < 200 ? 200 : txt.paintedWidth + 20 < root.width ? txt.paintedWidth + 10 : root.width
                        root.height = txt.paintedHeight + txt.font.pointSize
                        txt.width = item.width
                        txt.height = item.height - txt.font.pointSize
                        txt.update()
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true
        enabled: root.updater
        z: 6
        onClicked: {
            let component = Qt.createComponent("listViewer.qml")
            let pos = getAbsolutePosition( root )
            let meta = {
                "model" : root.model,
                "y"     : mouseY - 5,// ,pos["y"] +
                "xpos"  : mouseX + 5 + 160 >= root.width ? mouseX + 5 : mouseX + 5 + 160,//  + mouseX,
                "func"  : func,
                "z"     : 20
            }

            component.createObject( bitchItem, meta )

        }

        function getAbsolutePosition(node) {
              var returnPos = {};
              returnPos.x = 0;
              returnPos.y = 0;
              if(node !== undefined && node !== null) {
                  var parentValue = getAbsolutePosition(node.parent);
                  returnPos.x = parentValue.x + node.x;
                  returnPos.y = parentValue.y + node.y;
              }
              return returnPos;
          }
    }

    Item {
        id: bitchItem
        anchors.fill: parent
    }

    onWidthChanged: {
        txt.width = root.width
        txt.height = root.height - 20
        message.width = txt.paintedWidth < 200 ? 200 : txt.paintedWidth + 20 < root.width ? txt.paintedWidth + 10 : root.width
        root.height = txt.paintedHeight + txt.font.pointSize
        txt.width = item.width
        txt.height = item.height - txt.font.pointSize
        txt.update()
    }
    Component.onCompleted: txt.resize()
    function resize() { txt.resize() }
}
