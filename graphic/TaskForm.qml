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
    property var coreFunc: root.corefunc
    property var testData: root.testData
    property var cloadSrc: root.cloadSrc
    property var messages: root.messages
    property var exitlink: root.exitlink
    property var movelink: root.movelink
    property var execlink: root.execlink
    property bool isTask: true
    property bool edit: true

    Flickable {

        id: flic
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainColumn.implicitHeight

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

                Text {

                    id: testText
                    Layout.fillWidth: true
                    font.pointSize: 20
                    font.bold: true
                    text: testData["task"]
                    color: "white"

                    Rectangle {

                        color: "#808080"
                        width: parent.width
                        height: 2
                        y: testText.paintedHeight + 5

                    }

                    Text {

                        font.pointSize: 10
                        font.bold: true
                        color: "#808080"
                        text: testData["date_to"]
                        x: testText.paintedWidth + 10
                        y: testText.paintedHeight - paintedHeight

                    }

                }

                Image {

                    id: editImage
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: "qrc:/images/edit.svg"
                    sourceSize: Qt.size( 24, 24 )
                    visible: userData["status"] != "student" && userData["status"] != "updater" ? true : false
                    enabled: visible

                    ColorOverlay {
                        id: c0
                        anchors.fill: editImage
                        source: editImage
                        color: "#808080"
                        antialiasing: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: c0.color = "white"
                        onExited: c0.color = "#808080"
                        onClicked: {
                            movelink.running = true
                        }
                    }

                }

                Image {
                    id: deleteImage
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: "qrc:/images/remove.svg"
                    sourceSize: Qt.size( 24, 24 )
                    visible: userData["status"] != "student" && userData["status"] != "updater" ? true : false
                    enabled: visible

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
                Layout.preferredHeight: parent.height / 2
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
                        text: testData["description"]
                        selectByMouse: true
                        readOnly: true
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
                Layout.preferredHeight: parent.height / 2
                color: "#3A4047"
                radius: 5
                clip: true

                Platform.FileDialog {
                    id: fd
                    visible: false
                    fileMode: Platform.FileDialog.SaveFile
                    selectedNameFilter.index: 1
                    property string url: ""

                    onAccepted: {
                        cloadSrc.running = true
                        let fileName = currentFile.toString()
                        let file = fileName.slice( 8, fileName.length )
                        coreFunc.saveFile( file, url )
                        cloadSrc.running = true
                    }
                }

                ListView {

                    id: docsList
                    anchors.fill: parent
                    anchors.margins: 5
                    model: []

                    delegate: Text {

                        id: item
                        width: parent.width
                        height: 21
                        font.pointSize: 14
                        text: modelData["name"]
                        color: "white"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                item.font.italic = true
                                item.color = "grey"
                            }
                            onExited: {
                                item.font.italic = false
                                item.color = "white"
                            }
                            onClicked: {
                                fd.url = modelData["path"]
                                fd.nameFilters = [ "Files (*." + modelData["ext"] + ")" ]
                                fd.visible = true
                            }
                        }

                    }

                    Component.onCompleted: {

                        let newArray = []
                        let docsRaw = testData["docs"]
                        let docsArray = docsRaw.split(" ")
                        if ( docsArray.length >= 2 ) {
                            for ( let i = 0; i < docsArray.length; i++ ) {
                                let data = coreFunc.getDocs( docsArray[i] )["docs"]
                                if ( typeof(data) != "undefined" ) {
                                    data = data[0]
                                    newArray.push(data)
                                    docsList.model = newArray
                                }
                            }
                        }

                    }

                }

            }

            Rectangle {
                Layout.fillHeight: true
            }

        }   // ColumnLayout

        ScrollBar.vertical: ScrollBar{

            parent: flic.parent
            policy: ScrollBar.AsNeeded

        }

        Component.onCompleted: {
            execlink.running = true
            flic.contentHeight = mainColumn.implicitHeight
        }

    }

}
