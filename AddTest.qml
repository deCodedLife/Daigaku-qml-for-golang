import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1 as Platform

Item {

    id: root

    Layout.fillHeight: true
    Layout.fillWidth: true

    property var userData: coreFunc.loadUserData()
    property var coreFunc: corefunc
    property var comboBox: comboBox
    property var testData: testData
    property var cloadSrc: cloadSrc
    property var messages: messages
    property var exitlink: exitlink
    property var execlink: execlink
    property string selectedGroup: ""
    property string selectedTag: ""
    property bool edit: true
    property bool isTask: true

    ColumnLayout {

        id: mainColumn
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {

            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: 63
            Layout.maximumHeight: 63
            Layout.minimumHeight: 63

            TextField {

                id: testText
                Layout.fillWidth: true
                font.pointSize: 20
                font.bold: true
                text: edit ? testData["task"] : ""
                placeholderText: "Введите название темы"
                color: "white"

            }

            Image {
                id: deleteImage
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: "qrc:/images/remove.svg"
                sourceSize: Qt.size( 24, 24 )
                visible: edit

                ColorOverlay {
                    id: c1
                    anchors.fill: deleteImage
                    source: deleteImage
                    color: "#808080"
                    antialiasing: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: c1.color = "white"
                    onExited: c1.color = "#808080"
                    onClicked: {
                        messages.title = "Подтвердите действие"
                        messages.type = "info"
                        messages.question = true
                        let task = isTask ? "контрольную" : "домашнее"
                        messages.text = "Вы действительно хотите удалить " + task + ": " + testData["task"] + "?"
                        messages.show()
                        messages.addTask( function() {
                            let data
                            if ( isTask )
                                data = coreFunc.deleteTask( testData["id"] )
                            else
                                data = coreFunc.deleteHome( testData["id"] )
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
                                exitlink.running = true
                            }
                        } )
                    }
                }
            }

        }   // RowLayout

        Rectangle {
            height: 10
            color: Qt.rgba(0,0,0,0)
        }

        Text {

            text: "Описание"
            font.pointSize: 16
            color: "white"

        }

        Rectangle {

            Layout.preferredWidth: parent.width / 2
            Layout.preferredHeight: parent.height / 4
            color: "#3A4047"
            radius: 5
            clip: true

            Flickable {

                id: flickable
                anchors.fill: parent
                flickableDirection: Flickable.VerticalFlick
                contentHeight: commentText.implicitHeight
                anchors.margins: 2

                TextArea.flickable: TextArea {

                    id: commentText
                    font.pixelSize: 14
                    font.family: "Segoe UI Black"
                    color: "white"
                    wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                    placeholderText: "Описание файла"
                    readOnly: false
                    text: testData["description"]
                    selectByMouse: true
                    background: Rectangle{ color: Qt.rgba(0,0,0,0) }

                }

                ScrollBar.vertical: ScrollBar{

                    parent: flickable.parent
                    policy: ScrollBar.AsNeeded

                }

            }

        }

        Rectangle {
            height: 10
            color: Qt.rgba(0,0,0,0)
        }

        Text {

            text: "Файлы"
            font.pointSize: 16
            color: "white"

        }

        Rectangle {

            Layout.preferredWidth: parent.width / 2
            Layout.preferredHeight: parent.height / 4
            color: "#3A4047"
            radius: 5
            clip: true

            ListView {

                id: docsList
                anchors.fill: parent
                anchors.margins: 5
                property var loaded: coreFunc.getDocs(0,1)["docs"]
                model: []

                delegate: Rectangle {

                    id: item
                    width: parent.width
                    height: 21
                    color: Qt.rgba(0,0,0,0)

                    Text {

                        id: txt1
                        font.pointSize: 14
                        text: modelData["name"]
                        color: "white"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                txt1.font.italic = true
                                txt1.color = "grey"
                            }
                            onExited: {
                                txt1.font.italic = false
                                txt1.color = "white"
                            }
                        }

                    }

                    Image {
                        id: img
                        anchors.right: parent.right
                        width: 24
                        height: 24
                        source: "qrc:/images/remove.svg"
                        sourceSize: Qt.size( 24, 24 )

                        ColorOverlay {
                            id: c2
                            anchors.fill: img
                            source: img
                            color: "#808080"
                            antialiasing: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: c2.color = "white"
                            onExited: c2.color = "#808080"
                            onClicked: {
                                let array = docsList.model
                                array.splice(index,1)
                                docsList.model = array
                            }
                        }
                    }
                }


                Component.onCompleted: docsList.model = known()

                function known () {
                    let newArray = []
                    let docsRaw = testData["docs"]
                    let docsArray = docsRaw.split(" ")
                    if ( docsArray.length >= 2 ) {
                        for ( let i = 0; i < docsArray.length; i++ ) {
                            let data = coreFunc.getDocs( docsArray[i] )["docs"]
                            if ( typeof(data) != "undefined" ) {
                                data = data[0]
                                if ( data["permission"] != "0" ) {
                                    newArray.push(data)
                                }
                            }
                        }
                    }
                    return newArray
                }

            }

            RowLayout {
                id: area
                width: 24
                height: 24
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                visible: true

                Rectangle {
                    id: newMessage
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    radius: newMessage.height / 2
                    color: "#009687"

                    Image {
                        id: addImage
                        source: "qrc:/images/add.svg"
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
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

                                let newArray = []
                                newArray.push("Выберите документ")
                                let alternative = []
                                let array = docsList.loaded
                                let known = docsList.model

                                for ( let i = 0; i < array.length; i++ ) {
                                    let a = false
                                    if ( known.length > 0 ) {
                                        for ( let j = 0; j < known.length; j++ )
                                            if ( array[i]["id"] == known[j]["id"] ) a = true
                                    }
                                    if ( array[i]["permission"] == "0" )
                                        a = true
                                    if (!a) {
                                        alternative.push( array[i] )
                                        newArray.push( array[i]["name"] )
                                    }
                                }

                                let model = newArray
                                comboBox.title = "Выберите документ"
                                comboBox.model = model
                                comboBox.show()
                                comboBox.addTask(function( group ){
                                    if ( comboBox.selectedGroup != "" && comboBox.selectedIndex != 0 ) {
                                        comboBox.hide()
                                        let _array = docsList.model
                                        _array.push( alternative[ comboBox.selectedIndex - 1 ] )
                                        docsList.model = _array
                                        comboBox.selectedIndex = 0
                                        comboBox.selectedGroup = ""
                                    }
                                })
                            }

                        }

                    }

                }

            }

        }

        Rectangle {
            Layout.fillHeight: true
        }

        Button {
            Layout.preferredHeight: 40
            Layout.preferredWidth: parent.width / 2
            Layout.maximumWidth: parent.width / 2
            text: edit ? "Обновить" : "Добавить"
            highlighted: true
            onClicked: {
                let blyat = ""
                let data
                let words = docsList.model
                for ( let i = 0; i < words.length; i++ )
                    blyat = blyat + " " + words[i]["id"]
                if ( edit ) {
                    if ( isTask )
                        data = coreFunc.updateTest( testData["id"], testText.text, blyat, commentText.text )
                    else
                        data = coreFunc.updateHome( testData["id"], testText.text, blyat, commentText.text )
                } else {
                    if ( isTask )
                        data = coreFunc.addTest( selectedGroup, selectedTag, testText.text, blyat, selectedGroup, commentText.text )
                    else
                        data = coreFunc.addHome( selectedGroup, selectedTag, testText.text, blyat, selectedGroup, commentText.text )
                }
                if ( data.length != 8 ) {
                    messages.title = "Ошибка"
                    messages.type = "error"
                    messages.question = false
                    messages.text = data
                    messages.addTask(function(){})
                } else {
                    messages.text = "Успешно"
                    messages.title = "Информация"
                    messages.type = "info"
                    messages.question = false
                    messages.show()
                    messages.addTask(function(){
                        messages.text = ""
                        messages.title = ""
                        messages.type = "info"
                        messages.question = false
                        messages.show()
                    })
                    exitlink.running = true
                }
            }
        }

    }   // ColumnLayout

    Component.onCompleted: execlink.running = true

}
