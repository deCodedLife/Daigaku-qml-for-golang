import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

Item {
    id: root
    anchors.fill: parent

    property int isChoose: 0
    property var userData: coreFunc.loadUserData()
    property var coreFunc: root.coreFunc
    property var messages: root.messages
    property var comboBox: root.comboBox
    property var token: coreFunc.getToken( userData["username"], userData["password"] )
    property var tags: coreFunc.getTags()

    Material.theme: Material.Dark
    Material.accent: "#009687"

    Rectangle {
        id: topPanel
        width: parent.width
        height: 40
        color: "#282E33"
        y: -40        

        Rectangle {
            width: 1
            anchors {
                left: parent.left
                right: parent.right
            }
            color: "#242A2E"
        }

        ComboBox {
            id: chkBox
            anchors.left: parent.left
            anchors.leftMargin: 5
            width: parent.width - parent.width / 3
            height: 40
            model: []
            editable: true
            font.pixelSize: 14
            Component.onCompleted: updateF()
            font.letterSpacing: 1.5

            function updateF() {
                let array = []
                array.push("Выберите предмет")
                let tags = root.tags
                for ( let i = 0; i < tags.length; i++ )
                    array.push( tags[i]["tag"] )
                chkBox.model = array
                chkBox.update()
            }

            onCurrentTextChanged: {
                if ( currentIndex != 0 ) {
                    let array = []
                    let tasks = coreFunc.getTasksDb()
                    for ( let i = 0; i < tasks.length; i++ )
                        if ( tasks[i]["tag"] == chkBox.currentText ) array.push( tasks[i] )
                    listTasks.model = array
                }
            }
        }   //ComboBox
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
                    showLeftPanel.to = leftPanel.x == root.width ? root.width - root.width / 3 : root.width
                    showLeftPanel.running = true
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

    ListView {
        id: listTasks
        width: parent.width
        height: parent.height - 60
        model: [] //coreFunc.getTasksDb()
        spacing: 10
        y: 50
        clip: true

        delegate: ReferatItem {
            id: ittem
            width: parent.width - 20
            height: 63
            model: []
            func: func
            x: 10
            image: typeof(coreFunc.getUser( modelData["operator"] )["profile"]) != "undefined" ? coreFunc.getUser( modelData["operator"] )["profile"] : ""
            Component.onCompleted: console.log( JSON.stringify(ittem.image) )
            updater: userData["status"] == "updater" ? true : false
            onClicked: {
                messages.title = "Подтвердите действие"
                messages.type = "info"
                messages.question = true
                messages.text = "Вы действительно хотите выбрать реферат по теме: " + modelData["task"] + "?"
                messages.modelData = modelData
                messages.show()
                messages.addTask( function() {
                    if ( typeof( modelData["id"] ) != "undefined" ) {
                        let data = coreFunc.selectTask( modelData["id"] )
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
                        }
                    }
                    list.update()
                } )
            }

            Timer {
                id: func
                property int index: -1
                interval: 0
                onTriggered: {
                    let model = []
                    let students = coreFunc.getUsers( 1, userData["group"] )["users"]
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
                }
            }
        }
        NumberAnimation on width {
            id: toggleGrid
            to: listTasks.width == root.width ? listTasks.width - listTasks.width / 3 : root.width
            duration: 300
            running: false
            easing.type: Easing.InOutQuart
        }

    }   //ListView

    Rectangle {
        id: leftPanel
        width: parent.width / 3
        height: parent.height
        color: "#282E33"
        x: root.width

        MouseArea {
            anchors.fill: parent
            onClicked: {
                showLeftPanel.to = leftPanel.x == root.width ? root.width - root.width / 3 : root.width
                showLeftPanel.running = true
            }
        }

        ListView {
            id: list
            width: parent.width
            height: 3 * 48
            model: []
            delegate:
            Item {
                id: listItem
                width: parent.width
                height: 42
                clip: true

                Rectangle {
                    id: circle
                    width: 0
                    height: 0
                    color: "white"
                    opacity: .2

                    transform: Translate {
                        x: -circle.width / 2
                        y: -circle.height / 2
                    }

                    PropertyAnimation {
                        id: circleAnimation
                        target: circle
                        properties: "width,height,radius"
                        from: 0
                        to: listItem.width * 3
                        duration: 300
                        easing.type: Easing.OutInQuart
                        onStopped: {
                            circle.width = 0
                            circle.height = 0
                            showLeftPanel.to = leftPanel.x == root.width ? root.width - root.width / 3 : root.width
                            showLeftPanel.running = true
                        }
                    }
                }

                Rectangle {
                    id: item
                    width: root.width / 3
                    height: 42
                    color: "#282E33"

                    Text {
                        id: text
                        text: modelData
                        font.pixelSize: 16
                        anchors.centerIn: parent
                        color: "white"
                        font.letterSpacing: 1.5
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    hoverEnabled: true
                    onHoveredChanged: {
                        if ( containsMouse ) item.color = "#313B43"
                        else item.color = "#282E33"
                    }
                    onPressed: {
                        circle.x = mouseX
                        circle.y = mouseY
                        circleAnimation.start()
                    }
                    onClicked: {
                        circleAnimation.stop()
                        extFunc.setTimeout( function() {
                            let items = coreFunc.getTasksDb()
                            let array = []
                            if ( index == 0 ) {
                                for ( let i = 0; i < items.length; i++ )
                                    if ( items[i]["attached"].split("|")[0] == userData["username"] ) array.push( items[i] )
                                listTasks.model = array
                            } else if ( index == 1 ) {
                                for ( let i = 0; i < items.length; i++ )
                                    if ( items[i]["attached"].split("|")[0] == userData["username"] && items[i]["finished"] == 1 )
                                        array.push( items[i] )
                                listTasks.model = array
                            } else if ( index == 2 ) {
                                for ( let i = 0; i < items.length; i++ ) {
                                    if ( items[i]["attached"].split("|")[0] == userData["username"] ) {
                                        let dateTo = Date.fromLocaleString( Qt.locale(), items[i]["date_to"], "yyyy-MM-dd" )
                                        let nowDate = new Date()
                                        if ( dateTo.getTime() < nowDate.getTime() && items[i]["finished"] != 1 ) array.push( items[i] )
                                    }
                                }
                                listTasks.model = array
                            }
                            chkBox.currentIndex = chkBox.find( "Выберите предмет" )
                        }, 0)
                    }
                    onReleased: circleAnimation.stop()
                    onPositionChanged: circleAnimation.stop()
                }
            }

            Component.onCompleted: update()

            function update() {
                extFunc.setTimeout( function() {
                    coreFunc.uTasks()
                    let now_date = new Date()
                    let tasks = coreFunc.getTasksDb()
                    let picked = 0
                    let complited = 0
                    let fair = 0
                    for ( let i = 0; i < tasks.length; i++ ) {
                        let item = tasks[i]["attached"]
                        if ( item.split("|")[0] == userData["username"] ) {
                            picked += 1
                            if ( tasks[i]["finished"] == 1 ) complited += 1
                            let uDate = Date.fromLocaleString( Qt.locale(), tasks[i]["date_to"], "yyyy-MM-dd" )
                            if ( uDate.getTime() < now_date.getTime() && tasks[i]["finished"] != 1 ) fair += 1
                        }
                    }
                    let meta = ["Взято: " + picked, "Выполнено: " + complited, "Долги: " + fair]
                    list.model = meta
                }, 0)
            }
        }   // ListView
        NumberAnimation on x {
            id: showLeftPanel
            to: leftPanel.x >= root.width ? root.width - root.width / 3 : root.width
            duration: 300
            running: false
            easing.type: Easing.InOutQuart
            onStarted: toggleGrid.running = true
            onStopped: isChoose == 0 ? 1 : 0
        }
    }   // Rectangle

    onWidthChanged: update()
    onHeightChanged: update()

    function update() {
        if ( isChoose == 1 ) leftPanel.x = root.width - root.width / 3
        else leftPanel.x = root.width
        showLeftPanel.to = leftPanel.x == root.width ? root.width - root.width / 3 : root.width
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
