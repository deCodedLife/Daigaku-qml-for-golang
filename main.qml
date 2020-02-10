import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0
import AppCore 1.0

ApplicationWindow {
    id: root

    property var offline: 0
    property bool loaded: false

    property var pos: [ Screen.width / 2 - 320, Screen.height / 2 - 240 ]
    property var normal: [640, 480]
    property var maximized: [Screen.width, Screen.height - 1]

    Material.theme: Material.Dark
    Material.accent: "#009687"
    visible: true
    width: 750
    height: 500
    title: qsTr("大学")
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.NoDropShadowWindowHint
    font.capitalization: Font.MixedCase

    minimumHeight: 500
    minimumWidth: 720

    function maximize() {
        root.width = maximized[0]
        root.height = maximized[1]
        root.setX(0)
        root.setY(0)
    }

    function setNormal( position ){
        root.width = normal[0]
        root.height = normal[1]
        wind.windowMaximized = true
        if ( typeof(position) != "undefined" ) {
            root.x = ( position.x - root.width / 2 )
            root.y = pos2   // dont know but it work
        } else {
            root.setX( pos[0] )
            root.setY( pos[1] )
        }
    }

    Rectangle {
        id: bar
        width: parent.width
        height: 21
        color: "#3A4047"
        clip: true

        MouseArea {
            anchors.fill: parent
            property bool maximized: !wind.windowMaximized
            property point lastMousePos: Qt.point(0, 0)
            onPressed: {
                if ( maximized ) setNormal( Qt.point(mouseX, mouseY) )
                lastMousePos = Qt.point(mouseX, mouseY)
            }
            onMouseXChanged: { root.x += (mouseX - lastMousePos.x); pos[0] = ( root.x ) }
            onMouseYChanged: { root.y += (mouseY - lastMousePos.y); pos[1] = ( root.y ) }
        }

        Row {
            anchors.right: parent.right
            layoutDirection: Qt.LeftToRight
            width: bar.height * 3
            height: bar.height

            UpButton {
                image: "qrc:/images/minimize.svg"
                onClicked: root.visibility = "Minimized"
            }
            UpButton {
                id: wind
                image: "qrc:/images/windowed.svg"
                subImage: "qrc:/images/maximize.svg"
                windowMaximized: true
                onClicked: {
                    if ( windowMaximized ) {
                        windowMaximized = false
                        maximize()
                    } else {
                        windowMaximized = true
                        setNormal()
                    }
                }
            }
            UpButton {
                image: "qrc:/images/remove.svg"
                closed: true
                onClicked: root.close()
            }
        }
    }

    Loader {
        width: root.width
        height: root.height - bar.height
        y: bar.height
        id: loader
        active: true
        //asynchronous: true
        //onStatusChanged: if ( loader.status == Loader.Ready && loader.item == loginPage ) loader.item.core
    }

    Component {
        id: loginPage
        LoginPage {
            id: sfx
            anchors.fill: parent
            func: loadMainWindow
            cores: core
        }
    }

    Component {
        id: mainPage
        MainWindow {
            anchors.fill: parent
            messages: question
            comboBox: combobox
            exitFunc: exitFunction
            loadScr: changeLoadScreen
        }
    }

    Component {
        id: loaderPage
        Item {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "#18191D"
                visible: !root.loaded

                BusyIndicator {
                    width: 63
                    height: 63
                    smooth: true
                    anchors.centerIn: parent
                }

                Text {
                    id: debug
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    color: "white"
                    font.letterSpacing: 1.5
                }
            }
        }
    }

    // Next will be a functions for next pages!!! not timers // yes i know that it's kostil
    Timer {
        id: loadMainWindow
        property string username: ""
        property string password: ""
        interval: 0
        onTriggered: {
            root.loaded = false
            loader.sourceComponent = loaderPage
            core.update( loadMainWindow.username, loadMainWindow.password )
            core.close()
            root.loaded = true
            loader.sourceComponent = mainPage
        }
    }

    Timer {
        id: exitFunction
        property var core: exitFunction.core
        interval: 0
        onTriggered: {
            exitFunction.core.logout()
            root.close()
        }
    }

    Timer {
        id: changeLoadScreen
        property int state: 0 // can be only 0 or 1
        interval: 0
        onTriggered: {
            if ( state == 0 ) loadScreen.visible = true
            else loadScreen.visible = false
            state = state == 0 ? 1 : 0
        }
    }
    // Init next item for pages
    QuestionDialog {
        id: question
        width: root.width
        height: root.height - bar.height
        y: bar.height
        property var modelData: ({})
        text: ""
        signal finished()
        signal callBack()
        onOkClicked: {
            callBack()
            finished()
        }
        z: 5

        function addTask  ( cb ) {
            callBack.connect( cb )
            callBack.connect( function release () {
                callBack.disconnect( cb )
                callBack.disconnect( release )
            })
        }
    }

    ComboboxDialog {
        id: combobox
        width: root.width
        height: root.height - bar.height
        y: bar.height
        z: 6
        signal finished()
        signal callBack()
        onOkClicked: {
            callBack()
            finished()
        }

        function addTask  ( cb ) {
            callBack.connect( cb )
            callBack.connect( function release () {
                callBack.disconnect( cb )
                callBack.disconnect( release )
            })
        }
    }

    Rectangle {
        id: loadScreen // it is no loader Page !!!
        visible: false
        width: parent.width
        height: parent.height - bar.height
        y: bar.height
        color: Qt.rgba(0,0,0,0.6)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {}
            onHoveredChanged: {}
        }

        BusyIndicator {
            width: 63
            height: 63
            smooth: true
            anchors.centerIn: parent
        }
    }

    Component.onCompleted:  {
        loader.sourceComponent = loaderPage
        console.log("WTF?")
        let userData = core.loadUserData()
        if ( userData["username"] != "" ) {
            loadMainWindow.username = userData["username"]
            loadMainWindow.password = userData["password"]
            loadMainWindow.running  = true
        } else {
            root.offline = core.checkConnection()
            if ( root.offline != 1 )
                loader.sourceComponent = loginPage
            else
                console.log(" No internet connection ")
            root.loaded = true
        }
    }

    AppCore { id: core }
    onWidthChanged: if ( wind.windowMaximized == true ) normal[0] = root.width
    onHeightChanged: if ( wind.windowMaximized == true ) normal[1] = root.height
}
