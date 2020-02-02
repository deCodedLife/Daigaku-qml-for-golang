import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors.fill: parent
    Material.theme: Material.Dark
    Material.accent: "#009687"

    property var coreFunc: root.coreFunc
    property var messages: root.messages
    property string selectedGroup: ""

    Rectangle {
        id: rightPanel
        width: parent.width / 3 > 200 ? 200 : parent.width / 3
        height: parent.height
        x: parent.width
        color: "#282E33"

        StackView {
            id: stack
            anchors.fill: parent
            initialItem: tags
        }

        Component {
            id: panelItem
            Rectangle {
                property string group: ""

                anchors.fill: parent
                color: "#282E33"

                Text {
                    text: "Группа: " + group
                    font.pointSize: 12
                    color: "white"
                    smooth: true
                    anchors.left: parent.left
                    anchors.top: parent.top
                    font.letterSpacing: 1.5
                    anchors.margins: {
                        left: 5
                        top: 5
                    }
                }

                Image {
                    id: back
                    width: 16
                    height: 16
                    source: "qrc:/images/back.svg"
                    sourceSize: Qt.size( back.width, back.height )
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 7

                    ColorOverlay {
                        id: color
                        anchors.fill: back
                        source: back
                        color: "#808080"
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        hoverEnabled: true
                        onHoveredChanged: {
                            if ( containsMouse ) color.color = "white"
                            else color.color = "#808080"
                        }
                        onClicked: stack.push( tags )
                    }
                }

                Rectangle { width: parent.width; height: 10; color: "#313B43"; y: 40 }

                ColumnLayout {
                    id: layout
                    width: parent.width - 10
                    height: parent.height - 94
                    spacing: 5
                    x: 5
                    y: 52

                    Text {
                        text: "Добавить предмет"
                        font.pointSize: 12
                        height: 42
                        color: "white"
                        smooth: true
                        font.letterSpacing: 1.5
                    }

                    TextField {
                        id: subject
                        placeholderText: "Название предмета"
                        font.pointSize: 12
                        height: 42
                        smooth: true
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        id: curator
                        height: 42
                        editable: true
                        model: ["Выберите преподавателя"]
                        Layout.fillWidth: true
                        Component.onCompleted: {
                            let array = []
                            let prepods = coreFunc.getUsers(2)["users"]
                            array.push("Выберите преподавателя")
                            for ( let i = 0; i < prepods.length; i++ )
                                array.push( prepods[i] )
                            curator.model = array
                        }
                    }
                    Rectangle{ Layout.fillHeight: true; color: Qt.rgba(0,0,0,0) }
                }   // culumn
                Button {
                    text: "Готово"
                    height: 42
                    width: parent.width
                    highlighted: true
                    Layout.fillWidth: true
                    anchors.bottom: parent.bottom
                    onClicked: {
                        if ( curator.currentText != "Выберите преподавателя" ) {
                            messages.title = "Подтвердите действие"
                            messages.type = "info"
                            messages.question = true
                            messages.text = "Добавить предмет: " + subject.text + " куратор: " + curator.currentText + "?"
                            messages.addTask( function() {
                                let data = coreFunc.sendTag( subject.text, curator.currentText, selectedGroup )
                                if ( data.length != 8 ) {
                                    messages.title = "Ошибка"
                                    messages.type = "error"
                                    messages.question = false
                                    messages.text = data
                                } else {
                                    messages.text = ""
                                    messages.title = ""
                                    messages.type = "info"
                                    messages.show()
                                    messages.addTask(function(){})
                                    tagsList.model = coreFunc.igetTags( selectedGroup )["tags"]
                                }
                            } )
                            messages.show()
                        }
                    }
                }   // button
            } // Rectangle
        } // Component

        Component {
            id: tags
            ListView {
                id: list
                anchors.fill: parent
                model: coreFunc.igetGroups()["groups"]
                property int index: -1
                delegate: TagListItem {
                    width: parent.width
                    height: 42
                    text: modelData["group"]
                    onClicked: {
                        selectedGroup = modelData["group"]
                        tagsList.model = []
                        tagsList.model = coreFunc.igetTags( 0, modelData["group"] )["tags"]
                        stack.push( panelItem )
                        stack.currentItem.group = modelData["group"]
                    }
                    onStoped: {
                        if ( list.index != index ) {
                            if ( list.index >= 0 ) {
                                list.currentIndex = list.index
                                list.currentItem.color = "#282E33"
                            }
                            list.currentIndex = index
                            list.currentItem.color = "#009687"
                            list.index = index
                        }
                    }
                }
            }
        }

        NumberAnimation on x {
            id: toglePanel
            to: rightPanel.x >= root.width ? root.width - 200 : root.width
            duration: rightPanel.x >= root.width ? 100 : 150
            easing.type: Easing.InOutQuart
        }
    }

    GridView {
        id: tagsList
        width: parent.width - 200
        height: parent.height
        cellHeight: 250
        cellWidth: 250
        model: []
        clip: true
        delegate: Item {
            width: tagsList.cellWidth
            height: tagsList.cellWidth

            Rectangle {
                id: item
                anchors.fill: parent
                anchors.margins: 5
                radius: 5
                color: "#282E33"

                property string name: coreFunc.getCuratorTag( modelData["tag"] )
                property string icon: coreFunc.getProfile( item.name )["profile"]

                Text {
                    id: tag
                    text: modelData["tag"]
                    font.pointSize:  16
                    color: "white"
                    smooth: true
                    x: parent.width / 2 - tag.contentWidth / 2
                    y: 5
                    font.letterSpacing: 1.5
                }

                Image {
                    id: deleteImage
                    width: 24
                    height: 24
                    sourceSize: Qt.size( deleteImage.width, deleteImage.height )
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    source: "qrc:/images/remove.svg"
                    antialiasing: true

                    ColorOverlay {
                        id: overlay
                        anchors.fill: deleteImage
                        source: deleteImage
                        color: "#808080"
                        antialiasing: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if ( containsMouse ) overlay.color = "white"
                            else overlay.color = "#808080"
                        }

                        onClicked: {
                            messages.title = "Подтвердите действие"
                            messages.text  = "Вы действительно хотите удалить: " + modelData["tag"]
                            messages.type  = "info"
                            messages.question = true
                            messages.addTask(function(){
                                let data = coreFunc.deleteTag( selectedGroup, modelData["tag"] )
                                if ( data.length != 8 ) {
                                    messages.title = "Ошибка"
                                    messages.text  = data
                                    messages.type  = "error"
                                    messages.question = false
                                    messages.addTask(function(){})
                                }
                                else {
                                    messages.title = ""
                                    messages.text  = ""
                                    messages.type  = "info"
                                    messages.question = true
                                    messages.addTask(function(){})
                                    messages.show()
                                    tagsList.model = coreFunc.igetTags( 0, selectedGroup )["tags"]
                                }
                            })
                            messages.show()
                        }
                    }
                }

                Text {
                    id: group
                    text: "Группа: " + selectedGroup
                    font.pointSize:  16
                    color: "white"
                    smooth: true
                    x: 5
                    y: 5 + tag.contentHeight
                    font.letterSpacing: 1.5
                }

                RowLayout {
                    width: parent.width - 10
                    height: 68
                    x: 5
                    y: parent.height - (68 + 5)
                    Layout.fillWidth: true

                    Image {
                        source: item.name != "" ? item.icon : ""
                        width: 64
                        height: 64
                        sourceSize: Qt.size( 64, 64 )
                        layer.enabled: true
                        layer.effect: OpacityMask { maskSource: mask }
                        asynchronous: true
                        visible: item.icon != "" ? true : false
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
                        id: curatorName
                        text: item.name
                        font.pointSize: item.icon != "" ? 10 : 16
                        color: "white"
                        smooth: true
                        y: 5 + tag.contentHeight + group.contentHeight + 5
                        Component.onCompleted: {
                            if ( item.icon != "" )
                                curatorName.x = 64 + 10
                            else
                                curatorName.anchors.centerIn = parent
                        }
                        font.letterSpacing: 1.5
                    }
                }
            }// rectangle
        }   // item
    }

    onWidthChanged: resize()
    onHeightChanged: resize()

    function resize() {
        toglePanel.to = root.width - 200
        toglePanel.running = true
    }
}
