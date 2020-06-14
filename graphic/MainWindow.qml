import QtQuick 2.9
import AppCore 1.0
import QtQuick.Controls 2.5

Item {
    id: root

    property var userData: core.loadUserData()
    property int offline: core.checkConnection()
    property string token: core.getToken( root.userData["username"], root.userData["password"] )
    property var optionsPage: {
        "admin"   : [
                    {"image" : "qrc:/images/users.svg",     "text" : "Студенты"},
                    {"image" : "qrc:/images/timetable.svg", "text" : "Предметы"},
                    //{"image" : "qrc:/images/admin.svg",   "text" : "Панель управления"},
                    {"image":"qrc:/images/files.svg","text":"Файлы"},
                    {"image" : "qrc:/images/options.svg",   "text" : "Настройки"}],
        "curator" : [
                    //{"image":"qrc:/images/edit.svg","text":"Таблицы"},        // TODO
                    {"image":"qrc:/images/subject.svg",  "text":"Предмет"},
                    {"image":"qrc:/images/homeTasks.svg","text":"Дом. работа"},
                    {"image":"qrc:/images/tests.svg",    "text":"Контрольные"},
                    {"image":"qrc:/images/files.svg",    "text":"Файлы"},
                    {"image" : "qrc:/images/users.svg",  "text" : "Студенты"},
                    {"image" : "qrc:/images/timetable.svg", "text" : "Предметы"},
                    {"image":"qrc:/images/options.svg",  "text":"Настройки"}],
        "student" : [
                    {"image":"qrc:/images/timetable.svg","text":"Расписание"},
                    {"image":"qrc:/images/homeTasks.svg","text":"Домашка"},
                    {"image":"qrc:/images/tests.svg",    "text":"Контрольные"},
                    {"image":"qrc:/images/work.svg",     "text" : "Задания"},
                    {"image":"qrc:/images/messages.svg", "text":"Cообщения"},
                    {"image":"qrc:/images/options.svg",  "text":"Настройки"}]
    }
    property bool entered: false
    property var config: core.getConfig()
    property bool choose: false
    property var messages: root.messages
    property var comboBox: root.comboBox
    property var exitFunc: root.exitFunc
    property var loadScr: root.loadScr    

    Rectangle { anchors.fill: parent; color: "#18191D" }

    Rectangle {
        id: blackBackground
        signal callBack()
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.2)
        opacity: 0
        visible: false

        MouseArea {
            id: backgroundMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                toggleBackground.running = true
                blackBackground.callBack()
            }
        }

        function setFunc  ( cb ) {
            blackBackground.callBack.connect( cb )
            blackBackground.callBack.connect( function release () {
                blackBackground.callBack.disconnect( cb )
                blackBackground.callBack.disconnect( release )
            })
        }

        NumberAnimation on opacity {
            id: toggleBackground
            to: blackBackground.opacity == 0 ? 1 : 0
            duration: 50
            running: false
            easing.type: Easing.InOutQuart
            onStarted:
                if ( blackBackground.opacity == 0 )
                    blackBackground.visible = true
            onStopped: {
                if ( blackBackground.opacity == 0 )
                    blackBackground.visible = false
            }
        }
        z: 5
    }

    Rectangle {
        width: parent.width - 36
        height: parent.height
        x: 36
        color: "#18191D"
        clip: true

        StackView {
            id: pages
            width: parent.width
            height: parent.height

            property bool isTasks: false

            NumberAnimation on width {
                id: resizeStack
                to: root.width - 36
                duration: 300
                easing.type: Easing.InOutQuart
            }
        }

        NumberAnimation on opacity {
            to: 1
            duration: 500
            easing.type: Easing.InOutQuart
        }
        //pages
        Component { id: timeTable;  TimeTable    { func: getImage } }
        Component { id: messages;   MessagesPage { coreFunc: core; messages: root.messages } }
        Component { id: referats;   ReferatsPage { coreFunc: core; messages: root.messages; comboBox: root.comboBox } }
        Component { id: curator;    CuratorsDesk { coreFunc: core; messages: root.messages; comboBox: root.comboBox } }
        Component { id: options;    Options      { coreFunc: core; messages: root.messages; exitFunc: root.exitFunc; cloadSrc: root.loadScr; z:20 } }
        Component { id: adminPanel; AdminPanel   { coreFunc: core; messages: root.messages   } }
        Component { id: userList;   UserList     { coreFunc: core; messages: root.messages; comboBox: root.comboBox } }
        Component { id: tagsPanel;  TagsPanel    { coreFunc: core; messages: root.messages } }
        Component { id: docsPanel;  Docs         { coreFunc: core; messages: root.messages; comboBox: root.comboBox; cloadSrc: root.loadScr; } }
        Component { id: tasksList;  TasksList    { coreFunc: core; messages: root.messages; comboBox: root.comboBox; isTasks: pages.isTasks; cloadSrc: root.loadScr; } }
        Component { id: tagsCurator; TagsCurator { coreFunc: core; messages: root.messages; comboBox: root.comboBox; } }

        Timer {
            id: getImage
            interval: 0
            running: false
            property string date: ""
            property int change: 0
            onTriggered: {
                tagPanel.changeDate( getImage.date )
                if ( getImage.change == 1 || tagPanel.x >= root.width )
                    tagPanel.showAnimation()
                getImage.change = 0
            }
        }
        z: 1
    }

    TagPanel {
        id: tagPanel
        width: parent.width
        height: parent.height
        choose: checked
        animation: resizeStack
        coreFunc: core
        messages: root.messages
        cloadSrc: root.loadScr
        onShowed: {
            if ( leftPanel.width == 200 ) showPanel.running = true
            tagPanel.z = 10
            blackBackground.setFunc ( function () {
                tagPanel.showAnimation()
                tagPanel.z = 1
            })
            toggleBackground.running = true
        }
        onHided: {
            blackBackground.callBack()
            toggleBackground.running = true
        }
    }
    /*
    Timer {
        repeat: true
        interval: 15000
        onTriggered: {
            let offline = core.checkConnection()
            if ( offline != root.offline )
                core.update( root.userData["username"], root.userData["password"] )
        }
    }
    */

    Rectangle {
        id: leftPanel
        width: 36
        height: parent.height
        x: -32
        color: "#282E33"

        ListView {
            id: leftRow
            anchors.fill: parent
            property int selected: -1

            delegate: Clickable {
                image: modelData["image"]
                label: modelData["label"]
                onClicked: {
                    leftRow.enabled = false
                    pages.clear()
                    if ( userData["status"] == "student" || userData["status"] == "updater" ) {
                        switch( index ) {
                            case 0: pages.push( timeTable );break
                            case 1:
                                pages.isTasks = false
                                pages.push( tasksList )
                                break
                            case 2:
                                pages.isTasks = true
                                pages.push( tasksList )
                                break
                            case 3: pages.push( referats ); break
                            case 4: pages.push( messages ); break
                            case 5: pages.push( options );  break
                        }
                    } else if ( userData["status"] == "curator" ) {
                        switch( index ) {
                            case 0: pages.push( curator );   break
                            case 1:
                                pages.isTasks = false
                                pages.push( tasksList )
                                break
                            case 2:
                                pages.isTasks = true
                                pages.push( tasksList )
                                break
                            case 3: pages.push( docsPanel ); break
                            case 4: pages.push( userList );  break
                            case 5: pages.push( tagsCurator ); break
                            case 6: pages.push( options );   break
                        }
                    } else if ( userData["status"] == "admin" ) {
                        switch( index ) {
                            //case 0: pages.push( adminPanel ); break
                            case 0: pages.push( userList ); break
                            case 1: pages.push( tagsPanel );break
                            case 2: pages.push( docsPanel );break
                            case 3: pages.push( options );  break
                        }
                    }

                    if ( leftPanel.width == 200 ) {
                        blackBackground.callBack()
                        toggleBackground.running = true
                    }
                    if ( tagPanel.x < root.width ) tagPanel.showAnimation()
                    leftRow.enabled = true
                }
                onStoped: {
                    if ( leftRow.selected != index ) {
                        if ( leftRow.selected != -1 ) {
                            leftRow.currentIndex = leftRow.selected
                            leftRow.currentItem.color = "#282E33"
                            leftRow.currentItem.toggle()
                        }
                        leftRow.currentIndex = index
                        leftRow.currentItem.color = "#009687"
                        leftRow.selected = index
                    }
                }
            }
        }

        NumberAnimation on width {
            id: showPanel
            to: leftPanel.width == 36 ? 200 : 36
            duration: 100
            easing.type: Easing.InOutQuart
            running: false
            onStopped: {
                if ( leftPanel.width == 36 ) leftPanel.z = 1
                leftRow.width = leftPanel.width
            }
        }

        MouseArea {
            id: mouse
            width: leftPanel.width
            height: root.height - 42 * leftRow.model.length
            anchors.bottom: parent.bottom
            onClicked: {
                if ( leftPanel.width == 36 ) {
                    leftPanel.z = 10
                    blackBackground.setFunc( function () {
                        showPanel.running = true
                        leftPanel.z = 1
                    })
                    toggleBackground.running = true
                    showPanel.running = true
                } else {
                    blackBackground.callBack()
                    toggleBackground.running = true
                }
            }

        }

        NumberAnimation on x {
            id: viewAnimation
            to: 0
            duration: 500
            easing.type: Easing.InOutQuart
        }
    }//Rectangle

    onWidthChanged: {
        viewAnimation.running = true
        tagPanel.sizeChange( root.choose, root.width, root.height )
        if ( choose == true ) pages.width = root.width - root.width / 3 - 36
        else pages.width = root.width - 36
    }

    Component.onCompleted: {
        console.log( JSON.stringify(userData) )
        function getMeta( status, i ) {
            return {
                "image" : optionsPage[status][i]["image"],
                "label" : optionsPage[status][i]["text"]
            }
        }
        let array = [];
        if ( userData["status"] == "curator" ) {
            for ( let i = 0; i < optionsPage["curator"].length; i++ )
                array.push( getMeta( "curator", i ) )
            leftRow.model = array
        } else if ( userData["status"] == "admin" ) {
            for ( let i = 0; i < optionsPage["admin"].length; i++ )
                array.push( getMeta( "admin", i ) )
            leftRow.model = array
        } else if ( userData["status"] == "student" || userData["status"] == "updater" ) {
            for ( let i = 0; i < optionsPage["student"].length; i++ ) {
                array.push( getMeta( "student", i ) )
            }
            leftRow.model = array
        }
    }//Component

    Timer {
        id: duration;
        function setTimeout(cb, delayTime, a, b) {
            duration.interval = delayTime
            duration.repeat = false
            duration.triggered.connect(cb)
            duration.triggered.connect(function release () {
                duration.triggered.disconnect(cb)
                duration.triggered.disconnect(release)
            }); duration.start()
        }//func
    }//Timer

    Timer { id: checked; interval: 0; running: false; onTriggered: root.choose = root.choose == false ? true : false }
    AppCore { id: core }
}
