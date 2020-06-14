import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0

Item {

    id: root

    property var userData: coreFunc.loadUserData()
    property var coreFunc: coreFunc
    property var messages: messages
    property var comboBox: comboBox
    property var cloadSrc: cloadSrc

    property int selected: 0
    property bool isTasks: true
    property var currentTest: {"":""}
    property string selectedGroup: userData["group"]
    property string selectedTag: ""
    property bool loading: false

    Material.theme: Material.Dark
    Material.accent: "#009687"

    StackView {

        id: mainStack
        anchors.fill: parent
        onPushEnterChanged: cloadSrc.running = true
        onPushExitChanged: cloadSrc.running = true

        property bool open: true

    }

    Component.onCompleted: mainStack.push( list )

    Component {

        id: list

        Item {

            anchors.fill: parent

            ColumnLayout {

                anchors.fill: parent

                Rectangle {

                    Layout.fillWidth: true
                    height: 40
                    color: "#282E33"
                    visible: userData["status"] != "student" && userData["status"] != "updater" ? true : false
                    enabled: visible

                    Rectangle {
                        width: 1
                        height: parent.height
                        color: Qt.rgba(0,0,0,0.1)
                        anchors.left: parent.left
                    }

                    Text {
                        id: txt2
                        x: 10
                        y: 5
                        font.pointSize: 18
                        text: "Группа"
                        color: "white"
                    }

                    ComboBox {

                        id: groupsList
                        editable: true
                        width: parent.width / 3
                        height: 40
                        anchors.right: parent.right
                        model: []

                        property bool group: selectedGroup != "" ? false : true

                        onCurrentIndexChanged: {

                            if ( currentIndex != 0 ) {
                                if ( !group ) {
                                    txt2.text = "Предмет"
                                    selectedGroup = model[ currentIndex ]
                                    let data = coreFunc.getProfile( userData["username"] )
                                    let newArray = []
                                    newArray.push("Назад к группам")
                                    let raw = data["curatorTag"]
                                    let array = raw.split(" ")
                                    for ( let i = 0; i < array.length; i++ )
                                        newArray.push( array[i] )
                                    groupsList.enabled = false
                                    groupsList.model = newArray
                                    group = true
                                    groupsList.enabled = true

                                } else {
                                    if ( isTasks ) {
                                        if ( userData["status"] == "curator" ) {
                                            let array = []
                                            let data = coreFunc.getTest( 1, selectedGroup )["tests"]
                                            if ( typeof(data) != "undefined" ) {
                                                for ( let i = 0; i < data.length; i++ )
                                                    if ( data[i]["tag"] == model[ currentIndex ] )
                                                        array.push( data[i] )
                                            }
                                            testsList.model = array
                                        }
                                    } else {
                                        if ( userData["status"] == "curator" ) {
                                            let array = []
                                            let data = coreFunc.getHome( 1, selectedGroup )["tests"]
                                            if ( typeof(data) != "undefined" ) {
                                                for ( let i = 0; i < data.length; i++ )
                                                    if ( data[i]["tag"] == model[ currentIndex ] )
                                                        array.push( data[i] )
                                            }
                                            testsList.model = array
                                        }
                                    }
                                    selectedTag = model[ currentIndex ]
                                }
                            } else {
                                if ( group ) {
                                    txt2.text = "Группа"
                                    group = false
                                    selectedTag = ""
                                    selectedGroup = ""
                                    load()
                                    testsList.model = []
                                }
                            }

                        }

                        Component.onCompleted: load()

                        function load() {
                            let newArray = []
                            let array = coreFunc.igetGroups()["groups"]
                            for ( let i = 0; i < array.length; i++ )
                                newArray.push( array[i]["group"] )
                            newArray.unshift( "Выберите группу" )
                            groupsList.model = newArray
                        }

                    }

                }

                ListView {

                    id: testsList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5
                    spacing: 10

                    delegate: ReferatItem {
                        id: item
                        width: parent.width - 20
                        height: 63
                        model: []
                        text: modelData["task"]
                        x: 10
                        image: typeof(coreFunc.getUser( modelData["operator"] )["profile"]) != "undefined" ? coreFunc.getUser( modelData["operator"] )["profile"] : ""
                        onClicked: {
                            selected = parseInt(modelData["id"])
                            currentTest = modelData
                            if ( !cloadSrc.visible )
                                cloadSrc.running = true
                            mainStack.push( task )
                        }
                    }

                    Component.onCompleted: {

                        if ( isTasks ) {
                            if ( userData["status"] == "student" || userData["status"] == "updater" )
                                testsList.model = coreFunc.getTest(0, selectedGroup)["tests"]
                        } else {
                            if ( userData["status"] == "student" || userData["status"] == "updater" )
                                testsList.model = coreFunc.getHome(0, selectedGroup)["tests"]
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
                visible: selectedTag != ""

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
                                mainStack.open = false
                                mainStack.push( task )
                            }

                        }

                    }

                }

            }

        }

    }

    Component {

        id: task

        Item {

            anchors.fill: parent

            Timer {
                running: true
                interval: 0
                onTriggered: {
                    if ( !mainStack.open ) {
                        mainSide.loadScript0 = false
                        leftSideElements.enabled = false
                        leftSideElements.visible = false
                        forms.push( addForm )
                        forms.currentItem.edit = false
                    }
                    mainStack.open = true
                }
            }

            Rectangle {

                id: mainSide
                anchors.fill: parent
                color: "#18191D"

                property bool loadScript0: false
                property bool loadScript1: false

                RowLayout {

                    id: mainForm
                    anchors.fill: parent

                    StackView {

                        id: forms
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        initialItem: simpleForm

                    }

                    Component {

                        id: simpleForm

                        TaskForm {

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            coreFunc: root.coreFunc
                            messages: root.messages
                            testData: root.currentTest
                            cloadSrc: root.cloadSrc
                            exitlink: func1
                            movelink: func0
                            execlink: func2
                            isTask: isTasks
                            edit: true

                            Component.onCompleted: mainSide.loadScript0 = true

                        } // TaskForm

                    }

                    Component {

                        id: addForm

                        AddTest {

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            coreFunc: root.coreFunc
                            messages: root.messages
                            comboBox: root.comboBox
                            testData: root.currentTest
                            cloadSrc: root.cloadSrc
                            isTask: isTasks
                            selectedGroup: root.selectedGroup
                            selectedTag: root.selectedTag
                            exitlink: func0
                            execlink: func2

                            Component.onCompleted: mainSide.loadScript0 = true

                        } // TaskForm

                    }

                    Timer {

                        id: func2
                        interval: 0
                        running: false
                        onTriggered: mainSide.loadScript0 = true

                    }

                    Timer {

                        id: func0
                        interval: 0
                        running: false
                        onTriggered: {
                            leftSideElements.enabled = false
                            leftSideElements.visible = false
                            forms.clear()
                            forms.push( addForm )
                        }

                    }


                    Timer {

                        id: func1
                        interval: 0
                        running: false
                        onTriggered: {
                            mainStack.push(list)
                        }

                    }


                    ColumnLayout {

                        id: leftSideElements
                        Layout.preferredWidth: 350
                        Layout.minimumWidth: 350
                        Layout.maximumWidth: 350
                        Layout.fillHeight: true
                        spacing: 0
                        visible: userData["status"] != "student" && userData["status"] != "updater" ? true : false
                        enabled: visible

                        Rectangle {

                            id: searchElementPanel
                            Layout.fillWidth: true
                            height: 40
                            color: "#282E33"

                            Rectangle {
                                width: 1
                                height: parent.height
                                color: Qt.rgba(0,0,0,0.1)
                                anchors.left: parent.left
                            }

                            ComboBox {

                                id: usersList
                                anchors.fill: parent
                                editable: true

                                onCurrentIndexChanged: {
                                    if ( currentIndex != 0 ) {
                                        let newArray = []
                                        let array = userListElement.mainModel
                                        for ( let i = 0; i < array.length; i++ )
                                            if ( array[i].split(model[currentIndex]).length >= 2 )
                                                newArray.push( array[i] )
                                        userListElement.model = newArray
                                    } else
                                        userListElement.model = userListElement.mainModel
                                    mainSide.loadSrc()
                                }

                                Component.onCompleted: {
                                    let array = coreFunc.getUsers( 1, selectedGroup )["users"]
                                    if ( typeof( array ) != "undefined" ) {
                                        array.unshift("Студент")
                                        usersList.model = array
                                    }
                                }

                            }

                        }

                        Rectangle {

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#282E33"

                            Rectangle {
                                width: 1
                                height: parent.height
                                anchors.left: parent.left
                                color: Qt.rgba(0,0,0,0.1)
                            }

                            ListView {

                                id: userListElement
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 5
                                model: mainModel

                                property var mainModel: []

                                delegate: RowLayout {

                                    function select( data ) {
                                        chc = true
                                        currentUser.checked = true
                                        if ( data == "3" ) currentMark.currentIndex = 1
                                        if ( data == "4" ) currentMark.currentIndex = 2
                                        if ( data == "5" ) currentMark.currentIndex = 3
                                    }

                                    property bool chc: false

                                    id: userItem
                                    width: parent.width
                                    height: 40

                                    CheckBox {
                                        id: currentUser
                                        text: modelData
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        onCheckedChanged: {
                                            let data
                                            if ( !userItem.chc ) {
                                                if ( root.isTasks ) {
                                                    if ( !checked )
                                                        data = coreFunc.applyTest( currentTest["id"], currentMark.currentText, text, 1)
                                                    else
                                                        data = coreFunc.applyTest( currentTest["id"], currentMark.currentText, text )
                                                } else {
                                                    if ( !checked )
                                                        data = coreFunc.applyHome( currentTest["id"], currentMark.currentText, text, 1)
                                                    else
                                                        data = coreFunc.applyHome( currentTest["id"], currentMark.currentText, text )
                                                }
                                            }
                                            chc = false
                                        }
                                    }
                                    ComboBox {

                                        id: currentMark
                                        width: 21
                                        height: 21
                                        model: [2,3,4,5]
                                        currentIndex: 0
                                        font.pointSize: 12
                                        enabled: currentUser.checked

                                        onCurrentIndexChanged:  {
                                            let data
                                            if ( isTasks )
                                                data = coreFunc.applyTest( currentTest["id"], model[currentIndex], currentUser.text, 2 )
                                            else
                                                data = coreFunc.applyHome( currentTest["id"], model[currentIndex], currentUser.text, 2 )
                                        }

                                    }
                                }

                                Component.onCompleted: {

                                    userListElement.mainModel = coreFunc.getUsers( 0, selectedGroup )["users"]
                                    mainSide.loadSrc()

                                }

                            } // ListView

                        }   // Rectangle

                    }   // ColumnLayout

                }   // RowLayout

                Timer {
                    id: sugoi
                    interval: 1
                    repeat: true
                    running: true
                    onTriggered: {
                        if ( mainSide.loadScript0 && mainSide.loadScript1 ) {
                            if ( cloadSrc.visible ) cloadSrc.running = true
                            //ugoi.repeat = false
                            //sugoi.running = false
                        } else if ( !mainSide.loadScript1 || !mainSide.loadScript0 ) {
                            if ( !cloadSrc.visible ) cloadSrc.running = true
                        }
                    }
                }

                function loadSrc( model ) {
                    mainSide.loadScript1 = false
                    let data
                    let models = userListElement.model
                    console.log( JSON.stringify(userListElement.model) )
                    if ( !isTasks )
                        data = coreFunc.getHomeData( 0, currentTest["id"] )["tests"]
                    else
                        data = coreFunc.getTaskData( 0, currentTest["id"] )["tests"]
                    if ( typeof(data) != "undefined" ) {
                        for ( let i = 0; i < data.length; i++ ) {
                            if ( typeof( models ) != "undefined" ) {
                                for ( let j = 0; j < models.length; j++ ) {
                                    if ( models[j] == data[i]["user"] ) {
                                        userListElement.currentIndex = j
                                        userListElement.currentItem.select( data[i]["mark"] )
                                    }
                                }
                            }
                        }
                    }
                    mainSide.loadScript1 = true
                }

            }   // Rectangle
        }

    }


}
