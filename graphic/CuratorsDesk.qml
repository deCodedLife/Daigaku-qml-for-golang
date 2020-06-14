import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors.fill: parent

    property var coreFunc: root.coreFunc
    property var messages: root.messages
    property var comboBox: root.comboBox
    property var userData: coreFunc.loadUserData()
    property string selectedGroup: ""

    Rectangle {
        id: form
        width: parent.width - 200
        height: parent.height
        color: "#18191D"
        property bool ready: false

        ListView {
            id: listTasks
            width: parent.width
            height: parent.height - 10
            y: 5
            model: []
            spacing: 10
            clip: true

            delegate: ReferatItem {
                width: parent.width - 20
                height: 63
                x: 10
                image: coreFunc.getUser( modelData["operator"] )["profile"]
                updater: true
                func: func
                model: ["Удалить", "Назначить", "Подтвердить"]
                onClicked: {
                    messages.title = "Работа на тему"
                    messages.type = "info"
                    messages.question = false
                    messages.text = modelData["task"]
                    messages.modelData = modelData
                    messages.addTask( function() {} )
                    messages.show()
                }

                Timer {
                    id: func
                    property int index: -1
                    interval: 0

                    onTriggered: {
                        let model = ["Удалить", "Назначить", "Подтвердить"]
                        switch ( index ) {
                            case 0:
                                messages.title = "Подтвердите действие"
                                messages.type = "info"
                                messages.question = true
                                messages.text = "Вы действительно хотите удалить реферат по теме: " + modelData["task"] + "?"
                                messages.show()
                                messages.addTask( function() {
                                    let data = coreFunc.deleteTask( modelData["id"] )
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
                                        listTasks.model = coreFunc.getTasks("1", selectedGroup)["tasks"]
                                    }
                                } )
                                break
                            case 1:
                                let model = []
                                let students = coreFunc.getUsers(1)["users"]
                                model.push("Выберите студента")
                                for ( let i = 0; i < students.length; i++ )
                                    model.push( students[i] )
                                comboBox.title = "Список студентов"
                                comboBox.model = model
                                comboBox.show()
                                comboBox.addTask(function( group ){
                                    let data = coreFunc.selectStudent( modelData["id"], comboBox.selectedGroup ) // selectedGroup == selectedStudent
                                    //comboBox.show()
                                    if ( data.length != 8 ) {
                                        messages.title = "Ошибка"
                                        messages.type = "info"
                                        messages.question = false
                                        messages.text = data
                                        messages.addTask(function(){})
                                    }else {
                                        comboBox.hide()
                                        messages.title = "Сообщение"
                                        messages.text = "Студент " + comboBox.selectedGroup + " назначен выполнять реферат по теме: " + modelData["task"]
                                        messages.type = "info"
                                        messages.question = false
                                        messages.addTask(function(){})
                                    }
                                    messages.show()
                                })
                                break
                            case 2:
                                messages.title = "Подтвердите действие"
                                messages.type = "info"
                                messages.question = true
                                messages.text = "Вы действительно хотите подтвердить реферат по теме: " + modelData["task"] + "?"
                                messages.show()
                                messages.addTask( function() {
                                    let data = coreFunc.applyTask( modelData["id"] )
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
                                        listTasks.model = coreFunc.getTasks("1", selectedGroup)["tasks"]
                                    }
                                } )
                                break
                        }
                    }
                }
            }
            onStateChanged: form.ready
        }   //ListView
    }   // form rectangle

    Rectangle {
        id: rightPanel
        width: 200
        height: parent.height
        color: "#282E33"
        x: parent.width

        StackView {
            id: stack
            anchors.fill: parent
            initialItem: groups
        }

        Component {
            id: groups

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
                        listTasks.model = coreFunc.getTasks("1", modelData["group"])["tasks"]
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

        Component {
            id: panelItem

            Rectangle {
                id: panel
                anchors.fill: parent
                color: "#282E33"

                property string group: ""

                Text {
                    text: panel.group
                    font.pointSize: 14
                    smooth: true
                    color: "white"
                    x: 5
                    y: 5
                    font.letterSpacing: 1.5
                }

                Image {
                    id: back
                    width: 21
                    height: 21
                    source: "qrc:/images/back.svg"
                    sourceSize: Qt.size( back.width, back.height )
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 5

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
                        onClicked: stack.push( groups )
                    }
                }

                ColumnLayout {
                    id: layout
                    width: parent.width - 10
                    height: parent.height - 84
                    spacing: 5
                    x: 5
                    y: 42

                    Text {
                        id: txt
                        text: "Дата окончания"
                        font.pointSize: 12
                        color: "white"
                        smooth: true
                        Layout.fillWidth: true
                        height: 42
                        font.letterSpacing: 1.5
                    }

                    Item {
                        id: it
                        Layout.fillWidth: true
                        height: parent.width

                        TimeTable {
                            id: table
                            anchors.fill: parent
                            func: func
                            property string date: ""

                            Timer {
                                id: func
                                property string date: ""
                                property int change: 0  // dont delete!!!
                                interval: 0
                                running: false
                                onTriggered: table.date = date
                            }
                        }
                    }

                    TextField {
                        id: referat
                        placeholderText: "Тема реферата"
                        Layout.fillWidth: true
                        height: 42
                        font.pointSize: 14
                    }

                    Rectangle { color: Qt.rgba(0,0,0,0); Layout.fillHeight: true }
                }

                Button {
                    width: parent.width
                    height: 42
                    y: parent.height - 40
                    text: "Готово"
                    onClicked: {
                        let userData = coreFunc.getProfile()
                        let data = coreFunc.sendTask( selectedGroup, userData["curatorTag"], referat.text, table.date )
                        if ( data.length != 8 ) {
                            messages.title = "Error"
                            messages.text  = data
                            messages.type  = "error"
                            messages.question = false
                            messages.show()
                        } else {
                            coreFunc.uTasks()
                            listTasks.model = coreFunc.getTasks("1", selectedGroup)["tasks"]
                        }
                    }
                    highlighted: true
                } // button

                onHeightChanged: {
                    layout.width = panel.width - 10
                    layout.height = panel.height - 84
                    layout.y = 42
                    layout.update()
                }
            } //Rectangle
        } // Component

        NumberAnimation on x {
            id: togglePanel
            to: rightPanel.x >= root.width || rightPanel.x > root.width - 200 ? root.width - 200 : root.width
            duration: 200
            running: true
            easing.type: Easing.InOutQuart
        }
    }

    onWidthChanged: scale()
    onHeightChanged: scale()

    function scale() {
        togglePanel.to = root.width - 200
        togglePanel.running = true
    }
}
