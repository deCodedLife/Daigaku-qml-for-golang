import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.1 as Platform

Item {

    id: root
    anchors.fill: parent

    property var coreFunc: root.coreFunc
    property var comboBox: root.comboBox
    property var cloadSrc: root.cloadSrc
    property var messages: root.messageDlg

    Material.theme: Material.Dark
    Material.accent: "#009687"

    Rectangle {
        id: topPanel
        width: parent.width
        height: 40
        color: "#282E33"
        y: -40

        Text {
            id: label
            x: 15
            y: 5
            text: "Файлы"
            font.letterSpacing: 1.5
            font.pointSize: 18
            color: "white"
        }

        Item {
            width: 24
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 5
            y: 40 / 2 - 24 / 2

            Rectangle {
                id: r1; x: 1; y:8; width: 12; height: 2; antialiasing: true; z:9; color: "#808080";
                states: State { name: "rotated"; PropertyChanges {target: r1; rotation: -30 } }
                transitions: Transition { RotationAnimation { duration: 800; to: -30  } }
            }
            Rectangle {
                id: r2; x: 1; y:14; width: 12; height: 2; antialiasing: true; z:9; color: "#808080";
                states: State { name: "rotated"; PropertyChanges {target: r2; rotation: 30} }
                transitions: Transition { RotationAnimation { duration: 800; to: 30 } }
            }
            Rectangle {
                id: r3; x: 12; y:8; width: 12; height: 2; antialiasing: true; z:9; color: "#808080";
                states: State { name: "rotated"; PropertyChanges {target: r3; rotation: -30 } }
                transitions: Transition { RotationAnimation { duration: 800; to: -30  } }
            }
            Rectangle {
                id: r4; x: 12; y:14; width: 12; height: 2; antialiasing: true; z:9; color: "#808080";
                states: State { name: "rotated"; PropertyChanges {target: r4; rotation: 30} }
                transitions: Transition { RotationAnimation { duration: 800; to: 30 } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if ( containsMouse ) {
                        r1.color = "white"
                        r2.color = "white"
                        r3.color = "white"
                        r4.color = "white"
                    } else {
                        r1.color = "#808080"
                        r2.color = "#808080"
                        r3.color = "#808080"
                        r4.color = "#808080"
                    }
                }
                onClicked: {
                    showSearch.to = searchPanel.x >= root.width ? root.width - 200 : root.width
                    showSearch.running = true
                }
            }
        }   // Item

        NumberAnimation on y {
            to: 0
            duration: 300
            running: true
            easing.type: Easing.Linear
            onStopped: {
                r1.state = "rotated"
                r2.state = "rotated"
                r3.state = "rotated"
                r4.state = "rotated"
            }
        }
    }

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
        id: docList
        width: parent.width
        height: parent.height - 60
        y: 50
        clip: true
        spacing: 10
        model: mainModel
        property var mainModel: coreFunc.getDocs(0,1)["docs"]

        delegate: DocItem {
            id: item
            width: parent.width - 20
            height: 63
            model: ["Удалить","Доступ"]
            func: _func
            x: 10
            updater: true
            onClicked: {
                fd.url = modelData["path"]
                fd.nameFilters = [ "Files (*." + modelData["ext"] + ")" ]
                fd.visible = true
            }

            Timer {
                id: _func
                property int index: -1
                interval: 0

                onTriggered: {
                    let model = ["Удалить", "Доступ"]
                    switch ( index ) {
                        case 0:
                            messages.title = "Подтвердите действие"
                            messages.type = "info"
                            messages.question = true
                            messages.text = "Вы действительно хотите удалить файл: " + modelData["name"] + "?"
                            messages.show()
                            messages.addTask( function() {
                                let data = coreFunc.deleteDoc( modelData["id"] )
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
                                    docList.model = coreFunc.getDocs(0,1)["docs"]
                                }
                            } )
                            break
                        case 1:
                            let model = []
                            model.push("Публичный доступ")
                            model.push("Закрытый доступ")
                            comboBox.title = "Выберите тип доступа"
                            comboBox.model = model
                            comboBox.show()
                            comboBox.addTask(function( group ){
                                let permission
                                if ( comboBox.selectedGroup == model[0] ) permission = 1
                                if ( comboBox.selectedGroup == model[1] ) permission = 0
                                let data = coreFunc.changeDocPerm( modelData["id"], permission ) // selectedGroup == selectedStudent
                                if ( data.length != 8 ) {
                                    messages.title = "Ошибка"
                                    messages.type = "info"
                                    messages.question = false
                                    messages.text = data
                                    messages.addTask(function(){})
                                }else {
                                    comboBox.hide()
                                    messages.title = "Сообщение"
                                    messages.text = "Успешно"
                                    messages.type = "info"
                                    messages.question = false
                                    messages.addTask(function(){})
                                }
                                messages.show()
                            })
                            break
                    }
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
        visible: true

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
                        toggleAddPanel.to = root.width ? root.width - 200 : root.width
                        toggleAddPanel.running = true
                    }

                }

            }

        }

    }

    Rectangle {
        id: addPanel
        width: 200
        height: parent.height
        color: "#282E33"
        x: parent.width
        property bool open: false

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                toggleAddPanel.to = addPanel.x >= root.width ? root.width - 200 : root.width
                toggleAddPanel.running = true                
            }
        }

        Rectangle {
            height: parent.height
            width: 1
            anchors.left: parent.left
            color: Qt.rgba(0,0,0,0.1)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            Text {
                text: "Новый файл"
                font.pointSize: 18
                font.letterSpacing: 1.5
                color: "white"

            }
            Rectangle {
                width: parent.width
                height: 10
                color: Qt.rgba(0,0,0,0)

            }
            TextField {
                id: nameOfFile
                placeholderText: "Название"
                Layout.fillWidth: true
                height: 21

            }
            Rectangle {
                width: parent.width
                height: 10
                color: Qt.rgba(0,0,0,0)

            }
            Text {
                text: "Доступ"
                font.pointSize: 14
                font.letterSpacing: 1.5
                color: "white"

            }
            ComboBox {
                id: permission
                Layout.fillWidth: true
                height: 21
                model: ["Ограниченный","Открытый"]

            }
            Rectangle {
                width: parent.width
                height: 10
                color: Qt.rgba(0,0,0,0)

            }
            Rectangle {
                width: parent.width
                height: parent.width
                color: "#3A4047"

                Flickable {
                    id: flickable
                    anchors.fill: parent
                    flickableDirection: Flickable.VerticalFlick
                    contentHeight: flickable.height
                    anchors.margins: 2

                    TextArea.flickable: TextArea {
                        id: commentText
                        font.pixelSize: 12
                        font.family: "Segoe UI Black"
                        color: "white"
                        wrapMode: Text.Wrap
                        placeholderText: "Описание файла"

                    }

                    ScrollBar.vertical: ScrollBar{
                        parent: flickable.parent
                        policy: ScrollBar.AsNeeded

                    }

                }

            }
            Rectangle { Layout.fillHeight: true; color: Qt.rgba(0,0,0,0) }

            Button {
                Layout.fillWidth: true
                text: "Выбрать файл"
                highlighted: true
                height: 21
                onClicked: {
                    fileDialog.visible = true
                }
            }

        }

        NumberAnimation on x {
            id: toggleAddPanel
            to: addPanel.x >= root.width ? root.width - 200 : root.width
            easing.type: Easing.InOutQuart
            duration: 200
            running: false
            onStopped:  {
                addPanel.open = addPanel.x >= root.width ? false : true
            }
        }
    }

    Rectangle {
        id: searchPanel
        width: 200
        height: parent.height
        color: "#282E33"
        x: root.width
        property bool open: false

        MouseArea {
            anchors.fill: parent
            onClicked: {
                showSearch.to = searchPanel.x >= root.width ? root.width - 200 : root.width
                showSearch.running = true
                docList.model = docList.mainModel
                table.date = ""
                table.deselect()
                fileName.text = ""
            }
        }

        Rectangle {
            anchors.left: parent.left
            width: 1
            height: parent.height
            color: Qt.rgba(0,0,0,0.1)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            Text {
                text: "Поиск файлов"
                font.pointSize: 16
                x: 5
                y: 5
                color: "white"
                font.letterSpacing: 1.5

            }
            Rectangle {
                width: parent.width
                height: 10
                color: Qt.rgba(0,0,0,0)

            }
            Text {
                text: "по имени"
                font.pointSize: 14
                x: 5
                color: "white"
                font.letterSpacing: 1.5

            }
            TextField {
                id: fileName
                Layout.fillWidth: true
                height: 21
                placeholderText: "Имя файла"
            }
            Rectangle {
                width: parent.width
                height: 10
                color: Qt.rgba(0,0,0,0)

            }
            Text {
                text: "по дате"
                font.pointSize: 14
                x: 5
                color: "white"
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
            Rectangle {
                Layout.fillHeight: true
                color: Qt.rgba(0,0,0,0)
            }

            Button {
                Layout.fillWidth: true
                highlighted: true
                width: parent.width
                height: 21
                text: "Найти"
                onClicked: {
                    let newModel = []
                    let model = docList.mainModel
                    let byDate = false
                    let byName = false
                    if ( table.date != "" )
                        byDate = true
                    if ( fileName.text != "" )
                        byName = true
                    for ( let i = 0; i < model.length; i++ ) {
                        if ( byDate == true && byName == false ) {
                            if ( model[i]["date"] == table.date ) {
                                newModel.push( model[i] )
                            }
                        } else if ( byName == true && byDate == false ) {
                            if ( model[i]["name"].split( fileName.text ).length >= 2 ) {
                                newModel.push( model[i] )
                            }
                        } else {
                            let string = model[i]["name"].split( fileName.text ).length
                            if ( string >= 2 && model[i]["date"] == table.date ) {
                                newModel.push( model[i] )
                            }
                        }
                    }
                    docList.model = newModel
                }
            }
        }

        NumberAnimation on x {
            id: showSearch
            to: searchPanel.x >= root.width ? root.width - 200 : root.width
            duration: 200
            easing.type: Easing.InOutQuart
            running: false
            onStopped: {
                searchPanel.open = searchPanel.x >= root.width ? false : true
            }
        }
    }

    FileDialog{
        id: fileDialog
        title: "Выберите файл"
        visible: false
        nameFilters: [ "All files (*.*)" ]

        onAccepted: {
            if ( nameOfFile == "" ) {
                messages.title = "Error"
                messages.type = "error"
                messages.question = false
                messages.text = "Имя файла не указано"
                messages.addTask(function(){})
                messages.show()
                return
            }
            let comment = commentText.text
            let _fileUrl = fileUrl.toString()
            cloadSrc.running = true // show load screen
            let file;
            if (Qt.platform.os == "Windows")
                file = _fileUrl.slice( 8, _fileUrl.toString().length )
            else
                file =_fileUrl.slice( 7, _fileUrl.toString().length )
            let extArray = file.split( "." )
            let ext = ""
            if ( extArray.length >= 2 )
                ext = extArray[ extArray.length - 1 ]
            if ( comment == "" )
                comment = " "
            let array = []
            array.push( nameOfFile.text )
            array.push( comment )
            array.push( permission.currentIndex )
            array.push( ext )
            let data = coreFunc.sendImage( file, "/add-docs", array ) // send images * s - just for have
            if ( data.length != 11 ) {
                let text = data + "\n"
                let image = file
                messages.title = "Error"
                messages.type = "error"
                messages.question = false
                messages.text = text + image
                messages.addTask(function(){})
                messages.show()
            } else {
                docList.model = coreFunc.getDocs(0,1)["docs"]
            }
            cloadSrc.running = true // hide screen
        }

    }

    onWidthChanged: resize()
    onHeightChanged: resize()

    function resize() {
        showSearch.to = searchPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
        showSearch.running = searchPanel.open && searchPanel.x >= root.width ? true : false
        toggleAddPanel.to = addPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
        toggleAddPanel.running = addPanel.open && addPanel.x >= root.width ? true : false
    }
}
