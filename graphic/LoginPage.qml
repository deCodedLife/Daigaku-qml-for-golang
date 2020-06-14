import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

Item {
    id: root
    anchors.fill: parent

    Material.theme: Material.Dark
    Material.accent: "#009687"

    property var func: root.func
    property var cores: root.cores
    property int back: 0    

    Image {
        id: topImage
        width: parent.width / 2
        height: parent.height
        y: -parent.height
        source: "qrc:/images/top.png"
        antialiasing: true
        mipmap: true

        NumberAnimation on y {
            id: showTop
            to: 0
            duration: 400
            easing.type: Easing.InOutQuart
            running: true
            onStopped: showBottom.running = true
        }
    }

    Image {
        id: bottomImage
        width: parent.width / 2
        height: parent.height
        y: parent.height
        source: "qrc:/images/bottom.png"
        antialiasing: true
        mipmap: true

        NumberAnimation on y {
            id: showBottom
            to: 0
            duration: 300
            easing.type: Easing.InOutQuart
            running: false
            onStopped: showLogo.running = true
        }
    }

    Image {
        id: logo
        width: 300
        height: 350
        source: "qrc:/images/background.png"
        opacity: 0
        antialiasing: true
        x: (parent.width / 2) / 2 - logo.width / 2
        y: parent.height / 2 - logo.height / 2
        mipmap: true

        NumberAnimation on opacity {
            id: showLogo
            to: 1
            easing.type: Easing.InOutQuart
            duration: 600
            running: false
        }
    }

    Rectangle {
        id: form
        width: root.width / 2
        height: root.height
        x: root.width
        color: Qt.rgba(0.1,0.1,0.1,1)

        Rectangle {
            id: dashLine
            width: 3
            height: parent.height - parent.height / 3
            radius: 4
            y: -root.height
            x: 5
            smooth: true
            color: "#009687"

            NumberAnimation on y {
                id: dashLineAnimation
                to: form.height / 5
                duration: 200
                easing.type: Easing.Linear
                running: false
                onStopped: {
                    loginLabelAnimation.running = true
                    comboBoxAnimation.running = true
                    textFiledAnimation.running = true
                    buttonAnimation.running = true
                }
            }
        }

        Text {
            id: loginLabel
            x: parent.width
            y: parent.height / 5
            fontSizeMode: Text.Fit
            minimumPixelSize: 18
            font.pixelSize: 18
            text: "Выберите имя и введите пароль"
            color: "white"
            font.letterSpacing: 1.5

            NumberAnimation on x {
                id: loginLabelAnimation
                easing.type: Easing.OutInQuad
                to: 17
                duration: 300
                running: false
            }
        }

        ComboBox {
            id: names
            width: parent.width - 32
            height: 42
            x: parent.width
            y: dashLine.y + dashLine.height / 5
            model: [ "Студенты", "Преподаватели", "Администрация" ]
            Material.theme: Material.Dark
            Material.accent: "#009687"
            currentIndex: -1

            property int type: -1
            property int temp: 1
            property string group: ""
            property string name: ""

            NumberAnimation on x {
                id: comboBoxAnimation
                to: 16
                duration: 300
                running: false
                easing.type: Easing.OutInQuart
            }

            onCurrentIndexChanged: {
                if ( names.currentIndex != -1 && temp == 1 ) {
                    if ( names.type == -1 ) {
                        switch ( names.currentIndex ) {
                            case 0 :
                                let data = []
                                names.type = names.currentIndex
                                let array = cores.igetGroups()["groups"]
                                for ( let i = 0; i < array.length; i++ )
                                    data.push( array[i]["group"] )
                                names.model = data
                                break;
                            case 1 :
                                names.type = names.currentIndex
                                names.model = cores.getUsers(2)["users"]
                                break;
                            case 2 :
                                names.type = names.currentIndex
                                names.model = cores.getUsers(3)["users"]
                                break;
                        }
                    } else {
                        if ( names.group == "" && names.type == 0 ) {
                            if ( names.name == "" ) {
                                names.group = names.model[names.currentIndex]
                                names.model = cores.getUsers( 1, names.model[names.currentIndex] )["users"]
                                console.log( cores.getUsers( 1, names.model[names.currentIndex] )["users"] )
                            }
                        }
                        if ( names.name == "" && type == 0 && names.group != "" )   names.name = names.model[names.currentIndex]
                        if ( names.type == 1 || names.type == 2 ) names.name = names.model[names.currentIndex]
                    }
                    temp = 0
                    names.currentIndex = -1
                } else temp = 1
            }
        }

        TextField {
            id: password
            width: parent.width - 32
            height: 42
            x: parent.width
            y: parent.height / 2
            placeholderText: "Введите пароль"
            echoMode: TextField.Password

            Keys.onReturnPressed: login ( names.currentText, password.text )

            NumberAnimation on x {
                id: textFiledAnimation
                to: 16
                duration: 300
                running: false
                easing.type: Easing.OutInQuart
            }
        }

        Button {
            id: button
            width: parent.width - 32
            height: 42
            x: parent.width
            y: parent.height -  parent.height / 3
            text: "Войти"
            highlighted: true

            onClicked: {
                login ( names.currentText, password.text )
            }

            NumberAnimation on x {
                id: buttonAnimation
                to: 16
                duration: 300
                running: false
                easing.type: Easing.OutInQuart
            }
        }

        NumberAnimation on x {
            id: formAnimation
            to: root.width / 2
            duration: 300
            easing.type: Easing.InOutQuart
            running: true
            onStopped: {
                if ( root.back == 0 ) dashLineAnimation.running = true
                else {
                    root.func.username = names.currentText
                    root.func.password = password.text
                    root.func.running = true
                }
            }
        }
    }

    function login ( username, password ) {
        if ( back != 1 ) {
            let data = root.cores.getToken( username, password )
            if ( data.length < 50 ) {
                msg.title = "Login fail"
                msg.text = data
                msg.type = "error"
                msg.show()
            } else {
                root.back = 1
                showTop.to = -root.height
                showBottom.to = root.height
                showLogo.to = 0

                formAnimation.to = root.width
                formAnimation.duration = 600
                formAnimation.running = true
                showTop.running = true
            }
        }
    }

    onWidthChanged: {
        logo.opacity = 0
        topImage.y = root.height
        bottomImage.y = root.height
        form.x = root.width
        showTop.running = true
        formAnimation.to = root.width / 2
        formAnimation.running = true
    }

    onHeightChanged: {
        logo.opacity = 0
        topImage.y = root.height
        bottomImage.y = root.height
        form.x = root.width
        showTop.running = true
        formAnimation.to = root.width / 2
        formAnimation.running = true
    }

    QuestionDialog {
        id: msg
        width: root.width
        height: root.height
        question: false
        onOkClicked: question.show()
        z: 5
    }
}
