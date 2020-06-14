import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
// Just work

Window {
    id: root
    width: Screen.width
    height:Screen.height - 1
    visibility: "FullScreen"
    title: "Daigaku: image viewer"
    visible: true
    color: "#00000000"
    opacity: 1
    flags: Qt.FramelessWindowHint | Qt.WA_TranslucentBackground

    Material.theme: Material.Dark
    Material.accent: "#009687"

    property string source: root.source
    property int attached: 1
    property var config: root.config

    Rectangle {
        id: rect
        color: Qt.rgba(0,0,0,0.8)
        anchors.fill: parent

        BusyIndicator {
            id: indicator
            width: parent.width / 2
            height: parent.height / 2
            anchors.centerIn: parent
            opacity: 1

            NumberAnimation on opacity {
                to: 0
                duration: 200
                running: img.status == Image.Ready
                easing.type: Easing.InOutQuart
            }
        }

        Image {
            id: img
            source: root.attached == 1 ? "http://95.142.40.58/" + root.source : root.source
            anchors.fill: parent
            autoTransform: true
            fillMode: Image.PreserveAspectFit
            opacity: 1
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }
}



