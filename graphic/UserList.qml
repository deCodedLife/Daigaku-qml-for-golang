import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors.fill: parent

    property var coreFunc: root.coreFunc
    property var userData: coreFunc.loadUserData()
    property var messages: root.messages
    property var comboBox: root.comboBox
    property var groups: coreFunc.igetGroups()["groups"]
    property string selectedGroup: ""

    ColumnLayout {

        anchors.fill: parent

        Rectangle {
            id: topPanel
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.maximumHeight: 40
            anchors.top: parent.top
            color: "#282E33"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 5

                Text {
                    text: "Сортировать по группе: "
                    font.pointSize: 14
                    color: "white"
                    smooth: true
                    Layout.fillWidth: true
                    y: parent.height / 2 - paintedHeight / 2
                    font.letterSpacing: 1.5
                }

                ComboBox {
                    id: groupsPick
                    model: []
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onCurrentTextChanged: selected( currentText )
                    editable: true
                    font.letterSpacing: 1.5

                    function selected( currentText ) {

                        groupsPick.enabled = false
                        if ( userData["status"] == "updater" ) {

                            if ( currentText != "Выбрать группу" ) {
                                userList.model = coreFunc.getUsers(1, currentText)["users"]
                                selectedGroup = currentText
                            }

                        } else {

                            if ( currentText != "Выбрать группу" ) {
                                if ( currentText == "Преподаватели" )
                                    userList.model = coreFunc.getUsers(2)["users"]
                                else if ( currentText != "" )
                                    userList.model = coreFunc.getUsers(1, currentText)["users"]
                                selectedGroup = currentText
                            }

                        }
                        groupsPick.enabled = true

                    }

                    Component.onCompleted: {

                        let model = []
                        model.push( "Выбрать группу" )
                        let data = groups

                        if ( userData["status"] == "curator" ) {

                            let data = coreFunc.igetGroups( userData["username"] )["groups"]
                            for ( let i = 0; i < data.length; i++ )
                                model.push( data[i]["group"] )
                            groupsPick.model = model

                        } else {

                            for ( let i = 0; i < data.length; i++ )
                                model.push( data[i]["group"] )
                            model.push( "Преподаватели" )
                            groupsPick.model = model

                        }

                    }
                }
            }

        }

        ListView {
            id: userList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            clip: true
            spacing: 10
            model: []

            delegate: Rectangle {
                id: item
                width: parent.width
                height: 63
                radius: 4
                color: "#282E33"
                clip: true

                Image {
                    id: userIco
                    source: coreFunc.getUser( modelData )["profile"]
                    width: 48
                    height: 48
                    x: (parent.height - 48) / 2
                    y: (parent.height - 48) / 2
                    layer.enabled: true
                    asynchronous: true
                    layer.effect: OpacityMask { maskSource: mask }
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
                    id: userName
                    text: modelData
                    font.pointSize: 10
                    smooth: true
                    color: "white"
                    x: parent.height
                    y: userIco.y
                    font.letterSpacing: 1.5
                }

                Text {
                    id: params
                    text: selectedGroup
                    font.pointSize: 9
                    color: "white"
                    x: parent.height
                    y: (parent.height - (parent.height - 48)) - params.contentHeight / 2
                    font.letterSpacing: 1.5
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onClicked: {
                        togglePanel.to = togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                        togglePanel.running = !rightPanel.open ? true : false
                        stack.clear()
                        stack.push( userView )
                        let data = userData["status"] == "curator" ? coreFunc.getUser( modelData ) : coreFunc.getProfile( modelData )
                        stack.currentItem.icon = data["profile"]
                        stack.currentItem.name = modelData
                    }
                }
            }

            function load() {

                function concat( model, array ) {
                    for ( let i = 0; i < array.length; i++ )
                        model.push(array[i])
                }

                let model = []
                concat( model, coreFunc.getUsers(1)["users"] )
                concat( model, coreFunc.getUsers(2)["users"] )
                concat( model, coreFunc.getUsers(3)["users"] )
                userList.model = model

            }
        }

    }

    RowLayout {
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        Rectangle {
            id: newUserPane
            Layout.preferredHeight: 48
            Layout.preferredWidth: 48
            radius: newUserPane.height / 2
            color: "#009687"
            opacity: 0
            layer.enabled: true
            layer.effect: DropShadow {
                Layout.alignment: Layout.Center
                horizontalOffset: 2
                verticalOffset: 3
                radius: 8.0
                samples: 17
                color: "#80000000"
            }

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
                        togglePanel.to = togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                        togglePanel.running = !rightPanel.open ? true : false
                        stack.clear()
                        stack.push( addUser )
                    }
                }
            }

            NumberAnimation on opacity {
                id: toggleMenu
                to: newUserPane.opacity == 0 ? 1 : 0
                duration: newUserPane.opacity == 0 ? 100 : 200
                easing.type: Easing.InOutQuart
                running: true
            }
        }
    }

    Rectangle {
        id: rightPanel
        width: parent.width / 3 < 200 ? parent.width / 3 : 200
        height: parent.height
        color: "#282E33"
        x: parent.width

        property bool open: false

        StackView {
            id: stack
            anchors.fill: parent
        }

        Component {
            id: userView
            Item {
                id: item

                property string icon: ""
                property string name: ""

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onClicked: {}
                }

                Item {
                    id: userObjectIco
                    width:  parent.width
                    height: parent.width
                    clip: true

                    Image {
                        id: img
                        source: item.icon
                        anchors.fill: parent
                        smooth: true
                        asynchronous: true
                        property bool pressed: false
                    }

                    FastBlur {
                        id: blur
                        anchors.fill: img
                        source: img
                        radius: 0

                        NumberAnimation on radius {
                            id: blurAnimation
                            to: img.pressed ? blur.radius >= 32 ? 0 : 32 : 0
                            duration: blur.radius >= 150 ? 0 : 200
                            easing.type: Easing.InOutQuart
                            running: false
                            onStopped: blurAnimation.running = !img.pressed ? blur.radius >= 32 ? true : false : false
                        }
                    }

                    Text {
                        id: name
                        text: item.name
                        x: 5
                        y: parent.height
                        font.pointSize: 12
                        color: "white"
                        font.letterSpacing: 1.5

                        NumberAnimation on y {
                            id: toggleText
                            to: img.pressed ? name.y >= img.height ? img.height - name.paintedHeight - 5 : img.height : img.height
                            duration: 100
                            running: false
                            easing.type: Easing.InOutQuart
                            onStopped: toggleText.running = img.pressed ? name.y >= img.height ? true : false : false
                        }
                    }

                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onHoveredChanged: {
                            if ( containsMouse ) img.pressed = true
                            else img.pressed = false
                            blurAnimation.start()
                            toggleText.start()
                        }
                    }
                }

                ColumnLayout {
                    width: parent.width
                    height: parent.height - parent.width
                    y: parent.width

                    Rectangle {
                        width: parent.width
                        height: 42
                        color: "#282E33"

                        Rectangle {
                            id: wh2
                            anchors.fill: parent
                            color: "white"
                            opacity: 0.2
                            visible: false
                        }

                        Text {
                            text: "Превести студента"
                            color: "white"
                            font.pointSize: 12
                            anchors.centerIn: parent
                            font.letterSpacing: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onHoveredChanged: {
                                if ( containsMouse ) wh2.visible = true
                                else wh2.visible = false
                            }
                            onClicked: {
                                let model = []
                                model.push("Выбор группы")
                                for ( let i = 0; i < groups.length; i++ )
                                    model.push( groups[i]["group"] )
                                comboBox.title = "Перевод студунта"
                                comboBox.model = model
                                comboBox.show()
                                comboBox.addTask(function( group ){
                                    let data = coreFunc.changeGroup( name.text, comboBox.selectedGroup )
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
                                        groupsPick.selected( groupsPick.currentText )
                                    }
                                })
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 42
                        color: "#282E33"

                        Rectangle {
                            id: wh1
                            anchors.fill: parent
                            color: "white"
                            opacity: 0.2
                            visible: false
                        }

                        Text {
                            text: "Отчислить"
                            color: "white"
                            font.pointSize: 12
                            anchors.centerIn: parent
                            font.letterSpacing: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onHoveredChanged: {
                                if ( containsMouse ) wh1.visible = true
                                else wh1.visible = false
                            }
                            onClicked: {
                                messages.title = "Подтвердите действие"
                                messages.type = "info"
                                messages.question = true
                                messages.text = "Вы действительно хотите отчислить: " + name.text
                                messages.show()
                                messages.addTask( function() {
                                    let data = coreFunc.deleteUser( name.text )
                                    if ( data.length != 8 ) {
                                        console.log( data.length )
                                        messages.title = "Ошибка"
                                        messages.type = "error"
                                        messages.question = false
                                        messages.text = data
                                        messages.addTask(function(){})
                                    } else {
                                        messages.text = ""
                                        messages.title = ""
                                        messages.type = "info"
                                        messages.show()
                                        groupsPick.selected( groupsPick.currentText )
                                    }
                                } )
                            }
                        }
                    }

                    Rectangle { Layout.fillHeight: true }
                }

                MouseArea {
                    id: hideArea
                    width: parent.width
                    height: parent.height - parent.width - 42 * 2 - 20
                    y: parent.width + 42 * 2 + 20
                    propagateComposedEvents: true
                    onClicked: {
                        togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                        togglePanel.running = true
                    }
                }

                onHeightChanged: {
                    hideArea.y = item.width + 42 * 2 + 20
                    hideArea.height = item.height - item.width - 42 * 2 - 20
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    opacity: .3
                    smooth: true
                    color: "black"
                    anchors.left: parent.left
                }
            }
        }

        Component {
            id: addUser
            Item {
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onClicked: {
                        togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                        togglePanel.running = true
                    }
                }

                Text {
                    text: "Новый акаунт"
                    font.pointSize: 12
                    color: "white"
                    smooth: true
                    x: 5
                    y: 5
                    font.letterSpacing: 1.5
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
                        onClicked: {
                            togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                            togglePanel.running = true
                        }
                    }
                }

                ColumnLayout {
                    width: parent.width - 10
                    height: parent.height - 42 * 2
                    x: 5
                    y: 42

                    TextField {
                        id: username
                        placeholderText: "Введите ИО студента"
                        font.pointSize: 14
                        height: 42
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        id: userGroup
                        height: 42
                        editable: true
                        Layout.fillWidth: true
                        model: []
                        font.letterSpacing: 1.5
                        Component.onCompleted: {
                            let model = []
                            let data = groups
                            for ( let i = 0; i < data.length; i++ )
                                model.push( data[i]["group"] )
                            userGroup.model = model
                        }
                    }

                    CheckBox {
                        id: is_uploader
                        text: "Староста?"
                        height: 42
                        Layout.fillWidth: true
                        onCheckedChanged: {
                            if ( checked )
                                is_prepod.checked = false
                        }
                    }

                    CheckBox {
                        id: is_prepod
                        text: "Преподаватель?"
                        height: 42
                        Layout.fillWidth: true
                        visible: userData["status"] == "curator" ? false : true
                        onCheckedChanged: {
                            if ( checked )
                                is_uploader.checked = false
                        }
                    }

                    Rectangle { Layout.fillHeight: true }
                }

                Button {
                    text: "Готово"
                    highlighted: true
                    width: parent.width
                    height: 42
                    anchors.bottom: parent.bottom
                    onClicked: {
                        let status = ""
                        if ( is_uploader.checked ) status = "updater"
                        else if ( is_prepod.checked ) status = "curator"
                        else status = "student"
                        if ( username.text == "" ) {
                            messages.title = "Ошибка"
                            messages.type = "warn"
                            messages.question = false
                            messages.text = "Вы должны указать имя пользователя"
                            messages.show()
                            messages.addTask( function() {} )
                        } else {
                            messages.title = "Подтвердите действие"
                            messages.type = "info"
                            messages.question = true
                            messages.text = "Вы действительно хотите добавить пользователя: " + username.text + "?"
                            messages.show()
                            messages.addTask( function() {
                                let data = coreFunc.newUser( username.text, userGroup.currentText, status )
                                if ( data.length != 18 ) {
                                    messages.title = "Ошибка"
                                    messages.type = "error"
                                    messages.question = false
                                    messages.text = data
                                    messages.addTask(function(){})
                                } else {
                                    messages.text = "Пароль пользователя: " + data
                                    messages.title = "Информация"
                                    messages.question = false
                                    messages.type = "info"
                                    messages.addTask( function() {
                                        togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
                                        togglePanel.running = true
                                    } )
                                    groupsPick.selected( groupsPick.currentText )
                                }
                            } )
                        }
                    }
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    opacity: .3
                    smooth: true
                    color: "black"
                    anchors.left: parent.left
                }
            }
        }

        NumberAnimation on x {
            id: togglePanel
            to: rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
            running: false
            duration: rightPanel.x >= root.width ? 100 : 200
            easing.type: Easing.InOutQuart
            onStopped: rightPanel.open =  rightPanel.x >= parent.width ? false : true
        }
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

    onWidthChanged: resize()
    onHeightChanged:resize()

    function resize() {
        togglePanel.to = rightPanel.x >= root.width ? root.width / 3 <= 200 ? root.width - root.width / 3 : root.width - 200 : root.width
        togglePanel.running = rightPanel.open && rightPanel.x >= root.width ? true : false
    }
}
