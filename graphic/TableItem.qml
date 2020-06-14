import QtQuick 2.9

Item {
    id: root
    width: root.wd
    height: root.hg

    property int active: 1
    property int bettaTesting: 1
    property int is_weekDay: 0
    property string number: ""
    property int wd: 0
    property int hg: 0
    property bool selected: false

    signal clicked()

    Rectangle {
        id: item
        color: "#18191D"
        anchors.fill: parent

        Text {
            id: num
            text: root.number
            font.pixelSize: 16
            color: root.active == 1 ? "white" : "grey"
            smooth: true
            anchors.centerIn: parent
            font.letterSpacing: 1.5
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: {
                if ( root.is_weekDay == 0 && mouse.containsMouse && root.selected == false ) {
                    if ( root.active == 1 ) item.color = "#009687"
                    else item.color = "#E81123"
                } else if ( root.selected == false ) item.color = "#18191D"
            }
            onClicked: root.clicked()
        }
    }
    function deselect() { root.selected = false; item.color = "#18191D"; }
    function select() { root.selected = true; item.color = "#009687"; }
}
