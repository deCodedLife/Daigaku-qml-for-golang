import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors.fill: parent
    opacity: 0

    property var coreFunc: root.coreFunc
    property var exitFunc: root.exitFunc
    property var messages: root.messages
    property var cloadSrc: root.cloadSrc
    property var userData: coreFunc.loadUserData()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.2)

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }
    }

    Rectangle {
        id: panel
        width: 400
        height: parent.height - parent.height / 9
        x: parent.width / 2 - 200
        y: parent.height / 10
        color: "#282E33"
        radius: 5

        Item {
            id: imageItem
            width: parent.width
            height: 100

            Image {
                id: userIco
                width: 64
                height: 64
                sourceSize: Qt.size( userIco.width, userIco.height )
                source: userData["profile"] != "" ? userData["profile"] : "qrc:/images/profile.svg"
                layer.enabled: true
                layer.effect: OpacityMask { maskSource: mask }
                x: 10
                cache: false
                y: parent.height / 2 - 32

                ColorOverlay {
                    id: color
                    anchors.fill: parent
                    source: parent
                    color: "#808080"
                    smooth: true
                    visible: userData["profile"] != "" ? false : true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: fileDialog.visible = true
                }

                FileDialog {
                    id: fileDialog
                    title: "Выберете изображение/я для профиля"
                    folder: shortcuts.Images
                    visible: false
                    nameFilters: [ "Image files (*.jpg)" ]

                    function convert ( string ) {
                        let array = []
                        for ( let i = 0; i < string.length; i++ )
                            array.push( string[i] )
                        return array
                    }

                    onAccepted: {
                        cloadSrc.running = true // show load screen
                        let file = fileUrls[0].slice( 8, fileUrls[0].length )
                        let ext = fileUrls[0].slice( fileUrls[0].length - 3, 3)
                        let data = coreFunc.sendImage( file, "/upload-ico" ) // send images * s - just for have
                        if ( data.length != 8 ) {
                            let text = data + "\n"
                            let image = file
                            messages.title = "Error"
                            messages.type = "error"
                            messages.question = false
                            messages.text = text + image
                            messages.addTask(function(){})
                            messages.show()
                        } else {
                            let user = coreFunc.getMyProfile()
                            userIco.source = ""
                            userIco.source = user["profile"]
                            coreFunc.updateUser()
                            color.x = root.width
                            color.visible = false
                        }
                        cloadSrc.running = true // hide screen
                    }
                }
            }

            Rectangle {
                id: mask
                width: 64
                height: 64
                radius: mask.width / 2
                visible: false
                antialiasing: true
            }

            Text {
                id: userName
                text: userData["username"]
                font.letterSpacing: 1.5
                color: "white"
                font.pointSize: 16
                smooth: true
                x: parent.width / 2  - userName.contentWidth / 2
                y: parent.height / 2 - userName.contentHeight / 2
            }
        }

        Rectangle { width: parent.width; height: 10; color: "#303A42"; y: 100 }

        ListView {
            width: parent.width
            height: parent.height - (100 + 10)
            y: 110
            model: [
                "Сменить пароль",
                "Интерфейс //coming soon",
                "Выйти さよならですか"]
            clip: true

            delegate: Item {
                id: ground
                width: parent.width
                height: 41
                clip: true

                Rectangle {
                    id: circle
                    width: 0
                    height: 0
                    color: "white"
                    visible: index != 0
                    opacity: .2

                    transform: Translate {
                        x: -circle.width / 2
                        y: -circle.height / 2
                    }

                    PropertyAnimation {
                        id: circleAnimation
                        target: circle
                        properties: "width,height,radius"
                        to: ground.width * 3
                        from: 0
                        duration: 300
                    }
                }

                Rectangle {
                    id: wh
                    anchors.fill: parent
                    color: "white"
                    opacity: .2
                    visible: false
                }

                Text {
                    text: modelData
                    font.pointSize: 16
                    smooth: true
                    color: index == 0 ? "lightgrey" : "white"
                    anchors.centerIn: parent
                    font.letterSpacing: 1.5
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: index != 0
                    onHoveredChanged: {
                        if ( containsMouse ) wh.visible = true
                        else wh.visible = false
                    }
                    onPressed: {
                        circle.x = mouseX
                        circle.y = mouseY
                        circleAnimation.start()
                    }
                    onPositionChanged: {
                        circleAnimation.stop()
                        circle.width = 0
                        circle.height = 0
                    }
                    onReleased: {
                        circleAnimation.stop()
                        circle.width = 0
                        circle.height = 0
                    }
                    onClicked: {
                        if ( index == 2 ) {
                            exitFunc.core = coreFunc
                            exitFunc.running = true
                        } else if ( index == 0 ) {

                        }
                        circleAnimation.stop()
                    }
                }
            }
        }
    }

    NumberAnimation on opacity {
        id: showPanel
        to: root.opacity == 1 ? 0 : 1
        duration: 300
        running: true
        easing.type: Easing.InOutQuart
    }
}
