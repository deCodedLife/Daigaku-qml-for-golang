import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3

Item {
    id: root
    anchors.fill: parent

    property var userData: coreFunc.loadUserData()
    property string token: ""
    property var coreFunc: root.coreFunc
    property var messages: root.messageDlg

    Material.theme: Material.Dark
    Material.accent: "#009687"

    Rectangle {
        id: topPanel
        width: parent.width
        height: 40
        color: "#282E33"
        y: -40

        Image {
            id: operatorIcon
            width: 32
            height: 32
            sourceSize: Qt.size( 32, 32 )
            asynchronous: true
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: mask }
            y: parent.height / 2 - operatorIcon.height / 2
            x: 5
        }

        Rectangle {
            id: mask
            width: 32
            height: 32
            radius: 5
            visible: false
            antialiasing: true
        }

        Text {
            id: operatorText
            font.pointSize: 16
            color: "white"
            smooth: true
            x: operatorIcon.height + 5 * 2
            y: parent.height / 2 - operatorText.paintedHeight / 2
            font.letterSpacing: 1.5
        }

        Component.onCompleted: {
            extFunc.setTimeout( function() {
                let gcurator = coreFunc.getCurator()
                let userData = coreFunc.getUser( gcurator["operator"] )
                operatorIcon.source = userData["profile"]
                operatorText.text = userData["username"]
            }, 0)
        }

        NumberAnimation on y {
            to: 0
            duration: 300
            running: true
            easing.type: Easing.Linear
        }
    }

    Rectangle {
        id: messagesPage
        color: "#18191D"
        width: parent.width
        height: parent.height - 40
        y: 40
        clip: true
        opacity: 1

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20
            model: coreFunc.getMessages()
            delegate: MessagesDialog {

                func: func
                updater: userData["status"] == "updater" ? true : false

                Timer {
                    id: func
                    interval: 0
                    property int index: -1
                    property string text: modelData["message"]
                    property string date: modelData["date"]
                    property string pick: modelData["pick"]
                    onTriggered: {
                        switch (index) {
                            case 0:
                                textArea.message = [{"message" : text, "pick" : pick, "date" : date}]
                                if ( messageArea.y >= root.height) {
                                    messagesPage.height = root.height - 82
                                    toggleMArea.to = messageArea.y >= root.height ? root.height - 42 : root.height
                                    area.opacity = 0
                                    toggleMArea.running = true

                                }
                                textArea.text = text
                                textArea.edit = true
                                break
                            case 1:
                                let data = coreFunc.deleteMessage( pick, text, date )
                                if ( data.length != 8 ) {
                                    messages.title = "Ошибка"
                                    messages.type = "error"
                                    messages.text = data
                                    messages.question = false
                                    messages.show()
                                    messages.addTask( function(){})
                                } else root.modelUpdate()
                                break
                        }
                    }
                }
            }
        }
    }

    function modelUpdate() {
        coreFunc.uMessages()
        list.model = []
        list.model = coreFunc.getMessages()
    }

    RowLayout {
        id: area
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        visible: userData["status"] == "updater" ? true : false

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
                        toggleMenu.running = true
                    }
                }
            }
        }

        NumberAnimation on opacity {
            id: toggleMenu
            to: newMessage.opacity == 0 ? 1 : 0
            duration: 100
            running: false
            easing.type: Easing.InOutQuart
            onStopped: {
                messagesPage.height = root.height - 82
                toggleMArea.to = messageArea.y >= root.height ? root.height - 42 : root.height
                toggleMArea.running = true
            }
        }
    }

    Rectangle {
        id: messageArea
        width: parent.width
        height: 46
        y: parent.height
        color: "#282E33"

        Image {
            property int selected: 0
            id: picked
            width: 42
            height: 42
            source: selected == 0 ? "qrc:/images/pick.png" : "qrc:/images/pick_.png"
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size( 42, 42 )

            MouseArea {
                anchors.fill: parent
                onClicked: picked.selected = picked.selected == 0 ? 1 : 0
            }

            anchors.bottom: parent.bottom
        }

        Flickable {
            id: flickable
            width: parent.width - 48
            height: parent.height + 12
            flickableDirection: Flickable.VerticalFlick
            contentHeight: flickable.height
            x: 42
            y: 0

            TextArea.flickable: TextArea {

                property bool edit: false
                property var message: []

                Keys.onPressed: {
                    if ((event.key == Qt.Key_Return ) && ! (event.modifiers & Qt.ShiftModifier) ) {
                        messages.title = edit ? "ЗАМЕНИТЬ сообщение?" : "Отправить сообщение?"
                        messages.type = "warn"
                        messages.question = true
                        messages.text = edit ? message[0]["message"] + " на " +  textArea.text : textArea.text
                        messages.show()
                        messages.addTask( function() {
                            if ( edit ) {
                                let data = coreFunc.deleteMessage( message[0]["pick"], message[0]["message"], message[0]["date"] )
                                edit = false
                                message = []
                                if ( data.length != 8 ) {
                                    messages.title = "Ошибка"
                                    messages.type = "error"
                                    messages.text = data
                                    messages.question = false
                                    messages.show()
                                    messages.addTask( function(){})
                                    console.log(message[0]["pick"], message[0]["message"], message[0]["date"])
                                }
                            }
                            let data = coreFunc.sendMessage( picked.selected, textArea.text )
                            if ( data.length != 8 ) {
                                messages.type = "error"
                                messages.question = false
                                messages.title = "Error"
                                messages.text = data
                            } else {
                                messages.text = ""
                                messages.title = ""
                                messages.type = "info"
                                messages.show()
                                coreFunc.uMessages()
                                list.model = []
                                list.model = coreFunc.getMessages()
                                messagesPage.height = root.height - 40
                                toggleMArea.to = messageArea.y >= root.height ? root.height - 42 : root.height
                                area.opacity = 1
                                toggleMArea.running = true
                                textArea.text = ""
                                picked.selected = false
                            }
                        } )
                        event.accepted = true
                    } else event.accepted = false
                }
                background: Rectangle{ color: Qt.rgba(0,0,0,0) }
                id: textArea
                selectByMouse: true
                placeholderText: "Введите сообщение"
                font.pointSize: 12
                color: "white"
                focus: true
                wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                onTextChanged: {
                    messageArea.height = textArea.contentHeight + textArea.font.pointSize + 5 < 42 ? 42 : textArea.contentHeight + textArea.font.pointSize * 2 > 200 ? 200 : textArea.contentHeight + textArea.font.pointSize * 2
                    messageArea.y = root.height - messageArea.height
                }
            }
        }

        NumberAnimation on y {
            property bool opened: false
            id: toggleMArea
            to: messageArea.y >= root.height ? root.height - 42 : root.height
            duration: 200
            easing.type: Easing.InOutQuart
            running: false
            onStopped: {
                messageArea.height = textArea.contentHeight + textArea.font.pointSize > 200 < 42 ? 42 : textArea.contentHeight + textArea.font.pointSize > 200 ? 200 : textArea.contentHeight
                if ( messageArea.y >= root.height ) messagesPage.height = root.height - 82
                else messagesPage.height = root.height - 40
                opened = messageArea.y == root.height - 42 ? true: false
            }
        }

        onHeightChanged: messagesPage.height = root.height - 40 - messageArea.height
    }

    onHeightChanged: resize()

    function menu() { toggleMenu.running = true }
    function resize() {
        messageArea.y = toggleMArea.opened ? root.height - 42 : root.height
        messagesPage.height = toggleMArea.opened ? root.height - 40 - messageArea.height : root.height - 40
    }

    Timer {
        id: extFunc;
        function setTimeout(cb, delayTime, a, b) {
            extFunc.interval = delayTime
            extFunc.repeat = false
            extFunc.triggered.connect(cb)
            extFunc.triggered.connect(function release () {
                extFunc.triggered.disconnect(cb)
                extFunc.triggered.disconnect(release)
            }); extFunc.start()
        }//func
    }//Timer
}
