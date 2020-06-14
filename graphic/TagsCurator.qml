import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root

    anchors.fill: parent

    property var userData: coreFunc.loadUserData()
    property var coreFunc: coreFunc
    property var messages: messages
    property var comboBox: comboBox
    property var tagsList: []
    property string selectedGroup: ""

    Material.theme: Material.Dark
    Material.accent: "#009687"

    ColumnLayout {

        id: mainColumn
        anchors.fill: parent
        spacing: 0

        Rectangle {

            id: topPanel
            color: "#282E33"

            Rectangle {
                color: Qt.rgba(0,0,0,.1)
                width: 1
                height: parent.height
                anchors.left: parent.left
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.maximumHeight: 40

            Text {

                x: 5
                y: 5

                id: shit
                text: "Выбранная группа"
                color: "white"
                font.pointSize: 16
                font.letterSpacing: 1.5

            }

            ComboBox {

                id: groupsList
                model: []
                height: 40
                editable: true
                width: parent.width / 4
                anchors.right: parent.right

                onCurrentIndexChanged: {

                    if ( currentIndex != 0 ) {
                        tagsListView.model = coreFunc.igetTags( 0, model[ currentIndex ] )["tags"]
                        selectedGroup = model[ currentIndex ]
                    }
                }

                Component.onCompleted: {

                    let array = []
                    array.push("Выберите группу")
                    let data = coreFunc.igetGroups( userData["username"] )["groups"]
                    for ( let i = 0; i < data.length; i++ )
                        array.push( data[i]["group"] )
                    groupsList.model = array

                }

            }

        }

        ListView {

            id: tagsListView

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5
            spacing: 10
            clip: true

            model: []

            delegate: ReferatItem {

                width: parent.width - 20
                height: 63
                x: 10
                updater: true
                id: item
                remove: true
                model: ["Удалить"]
                func: func
                text: modelData["tag"]
                image: ""

                Timer {
                    id: func
                    interval: 0
                    running: false
                    onTriggered: {
                        messages.title = "Подтвердите действие"
                        messages.type = "info"
                        messages.question = true
                        messages.text = "Вы действительно хотите удалить предмет: " + modelData["tag"] + "?"
                        messages.show()
                        messages.addTask( function() {
                            let data = coreFunc.deleteTag( selectedGroup, modelData["tag"], modelData["curator"] )
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
                                tagsListView.model = coreFunc.igetTags( 0, selectedGroup )["tags"]
                            }
                        } )
                    }
                }

                Component.onCompleted: {
                    let data = coreFunc.getUser(modelData["curator"])["profile"]
                    item.image = typeof(data) != "undefined" ? data : ""
                    operator = modelData["curator"]
                }

            }

        }

    }

    RowLayout {
        id: area
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        visible: selectedGroup != "" ? true : false
        enabled: selectedGroup != "" ? true : false

        Rectangle {
            id: newMessage
            Layout.preferredHeight: 48
            Layout.preferredWidth: 48
            radius: newMessage.height / 2
            color: "#009687"

            Image {
                id: addImage
                source: "qrc:/images/add.svg"
                Layout.preferredHeight: 48
                Layout.preferredWidth: 48
                sourceSize: Qt.size( addImage.width, addImage.height )
                anchors.centerIn: parent

                ColorOverlay {
                    source: addImage
                    anchors.fill: addImage
                    color: "white"
                    antialiasing: true
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onClicked: {
                        let model = []
                        model.push("Выберите предмет")
                        for ( let i = 0; i < tagsList.length; i++ ) {
                            let surname = tagsList[i]["curator"].split(" ")
                            model.push( tagsList[i]["tag"] + " -" + surname[1] )
                        }
                        comboBox.title = "Выбор предмета"
                        comboBox.model = model
                        comboBox.show()
                        comboBox.addTask(function( group ){
                            let data = coreFunc.sendTag( tagsList[ comboBox.selectedIndex - 1 ]["tag"], "0", selectedGroup )
                            comboBox.show()
                            if ( data.length != 8 ) {
                                messages.title = "Ошибка"
                                messages.type = "info"
                                messages.question = false
                                messages.text = data
                                messages.show()
                                comboBox.hide()
                                messages.addTask(function(){})
                            }else {
                                comboBox.hide()
                                tagsListView.model = coreFunc.igetTags( 0, selectedGroup )["tags"]
                            }
                        })
                    }

                }

            }

        }

    }

    Component.onCompleted: {

        let array = []
        let data = coreFunc.getUsers(2)["users"]
        for ( let i = 0; i < data.length; i++ ) {

            let userObject = coreFunc.getProfile( data[i] )

            let object = {}

            let tagObj = userObject["curatorTag"]
            let tags = tagObj.split(" ")

            for ( let j = 0; j < tags.length; j++ ) {
                object["tag"] = tags[j]
                object["curator"] = userObject["name"]
                array.push( object )
                object = {}
            }

        }
        tagsList = array

    }

}
