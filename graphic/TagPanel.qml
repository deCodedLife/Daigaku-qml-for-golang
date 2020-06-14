import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0
import "qrc:/sources/core.js" as JsLib
import QtGraphicalEffects 1.0

Rectangle {
    id: chooseTag
    width: parent.width / 3
    height: parent.height
    x: parent.width
    color: "#282E33"

    signal showed()
    signal hided()

    property var animation: chooseTag.animation
    property var choose: chooseTag.choose
    property var coreFunc: chooseTag.coreFunc
    property var cloadSrc: chooseTag.cloadSrc
    property var messages: chooseTag.messages
    property var imageModel: []
    property var userData: coreFunc.loadUserData()
    property variant window;
    property var token: coreFunc.getToken( userData["username"], userData["password"] )
    property string selectedTag: ""
    property bool display: false

    StackView {
        id: stack
        width: chooseTag.width / 3
        height: chooseTag.height - 40
        y: 40
        initialItem: images
    }

    Rectangle {
        id: menu
        property int selected: 0
        width: chooseTag.width / 3
        height: 40
        color: "#282E33"

        Rectangle {
            width: parent.width / 2
            height: parent.height
            anchors.left: parent.left
            color: "#282E33"

            Text {
                id: dateText
                text: "Дата"
                font.pointSize: 14
                color: "#009687"
                smooth: true
                anchors.centerIn: parent
                font.letterSpacing: 1.5
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {
                    if ( menu.selected != 0 ) {
                        menu.selected = 0
                        bottomAnimation.running = true
                        stack.push( images )
                        stack.currentItem.model = chooseTag.imageModel
                    }
                }
            }
        }   // sub menu Rectangle

        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "#282E33"
            anchors.right: parent.right

            Text {
                id: tagText
                text: "Предмет"
                font.pointSize: 14
                color: "#808080"
                smooth: true
                anchors.centerIn: parent
                font.letterSpacing: 1.5
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {
                    if ( menu.selected != 1 ) {
                        menu.selected = 1
                        bottomAnimation.running = true
                        stack.push( tagList )
                    }
                }
            }
        }

        Rectangle {
            id: bottom
            width: menu.width / 2
            height: 2
            x: 0
            color: "#009687"
            anchors.bottom: parent.bottom

            NumberAnimation on x {
                id: bottomAnimation
                to: menu.selected == 0 ? 0 : menu.width / 2
                duration: 100
                running: false
                easing.type: Easing.InOutQuart
                onStarted: {
                    if ( menu.selected != 1 ) {
                        tagText.color = "#808080"
                        dateText.color = "#009687"
                    } else {
                        tagText.color = "#009687"
                        dateText.color = "#808080"
                    }
                }
            }
        }
    }   // menu Rectangle

    Component {
        id: images

        Item {
            anchors.fill: parent
            property var model: []

            onModelChanged: imageList.model = model

            ListView {
                id: imageList
                width: parent.width
                height: display ? parent.height - 42 : parent.height
                model: parent.model
                property int index: -1

                delegate: TagListItem {

                    Image {
                        width: 24
                        height: 24
                        sourceSize: Qt.size( 24, 24 )
                        x: parent.width - 29
                        y: 9
                        source: "qrc:/images/remove.svg"
                        visible: userData["status"] == "updater" ? true : false

                        ColorOverlay {
                            id: color
                            anchors.fill: parent
                            source: parent
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
                                messages.title = "Подтвердите удаление"
                                messages.text  = "Удалить изображение: " + typeof(modelData["date"]) != "undefined" ?  modelData["tag"] + modelData["date"] :  modelData["tag"]
                                messages.question = true
                                messages.addTask( function(){
                                    let data = coreFunc.deleteImage( modelData["image"] )
                                    if ( data.length != 8 ) {
                                        messages.title = "Error"
                                        messages.type = "error"
                                        messages.text = data
                                        messages.question = false
                                        messages.addTask( function(){} )
                                    } else {
                                        messages.title = ""
                                        messages.text = ""
                                        messages.type = "info"
                                        messages.question = true
                                        messages.addTask( function(){} )
                                        messages.show()

                                        let oldArray = imageList.model
                                        let newArray = []
                                        for ( let i = 0; i < oldArray.length; i++ ) {
                                            if ( oldArray[i]["image"] != modelData["image"] )
                                                newArray.push( oldArray[i] )
                                        }
                                        coreFunc.uImages()
                                        stack.currentItem.model = newArray
                                    }
                                })
                                messages.show()
                            }
                        }
                    }

                    width: parent.width
                    height: 42
                    text: typeof(modelData["date"]) != "undefined" ?  modelData["tag"] + " " + modelData["date"] :  modelData["tag"]
                    onStoped: {
                        if ( imageList.index != index ) {
                            if ( imageList.index >= 0 ) {
                                imageList.currentIndex = imageList.index
                                imageList.currentItem.color = "#282E33"
                            }
                            imageList.currentIndex = index
                            imageList.currentItem.color = "#009687"
                            imageList.index = index
                        }
                    }
                    onClicked: {
                        let component = Qt.createComponent("ImageViewer.qml")
                        window = component.createObject( chooseTag, { "source" : modelData["image"], "config" : coreFunc.getConfig() } )
                        window.show()
                    }
                }
            }

            Button {
                id: addImage
                width: parent.width
                anchors.bottom: parent.bottom
                height: 42
                highlighted: true
                text: "Добавить"
                visible: selectedTag != "" && userData["status"] == "updater" ? true : false
                onClicked: fileDialog.visible = true
            }

            Component.onCompleted: {
                display = selectedTag != "" && userData["status"] == "updater" ? true : false
            }
        }
    }

    Component {
        id: tagList

        ListView {
            id: list
            width: parent.width
            height: parent.height - 42
            model: coreFunc.getTags()
            property int index: -1

            delegate: TagListItem {
                width: parent.width
                height: 42
                text: modelData["tag"]
                onStoped: {
                    if ( list.index != index ) {
                        if ( list.index >= 0 ) {
                            list.currentIndex = list.index
                            list.currentItem.color = "#282E33"
                        }
                        list.currentIndex = index
                        list.currentItem.color = "#009687"
                        list.index = index
                    }
                }
                onClicked: {
                    stack.push( images )
                    menu.selected = 0
                    bottomAnimation.running = true
                    selectedTag = modelData["tag"]
                    stack.currentItem.model = coreFunc.getImages( modelData["tag"] )
                    display = selectedTag != "" && userData["status"] == "updater" ? true : false
                }
            }
        }
    }

    MouseArea {
        id: ms
        property int size: chooseTag.height - 42 * stack.currentItem.model.length - 40
        width: chooseTag.width
        height: display ? size - 42 : size
        y: 40 + 42 * stack.currentItem.model.length
        onClicked: showTags.running = true
    }

    NumberAnimation on x {
        id: showTags
        to: chooseTag.x >= chooseTag.width ? chooseTag.width - chooseTag.width / 3 : chooseTag.width
        easing.type: Easing.InOutQuart
        duration: 300
        running: false
        onStarted: {
            if ( showTags.to == chooseTag.width - chooseTag.width / 3 ) {
                chooseTag.animation.to = chooseTag.width - chooseTag.width / 3 - 36
                showed()
            } else {
                chooseTag.animation.to = chooseTag.width - 36
                hided()
            }
            chooseTag.choose.running = true
            chooseTag.animation.running = true;
            selectedTag = ""
        }
    }

    FileDialog {
        id: fileDialog
        title: "Выберете нужные изображение/я"
        folder: shortcuts.Images
        visible: false
        nameFilters: [ "Image files (*.jpg *.png)" ]
        signal acceptFunc()
        selectMultiple: true

        onAccepted: {
            if ( fileUrls.length >= 1 ) {
                let errorCounter = []
                cloadSrc.running = true // show load screen
                for ( let i = 0; i < fileUrls.length; i++ ) {
                    let file = fileUrls[i].slice( 8, fileUrls[i].length )
                    let data = coreFunc.sendImage( file, "/add-image/" + coreFunc.getHashed(selectedTag) ) // send images
                    if ( data.length != 8 )
                        errorCounter.push( {"image:" : fileUrls[i], "text" : data} )
                }
                coreFunc.uImages( selectedTag )
                stack.currentItem.model = coreFunc.getImages( selectedTag )
                cloadSrc.running = true // hide screen
                if ( errorCounter.length >= 1 ) {
                    for ( let j = 0; j < errorCounter.length; j++ ) {
                        let text = errorCounter[j]["text"] + "\n"
                        let image = errorCounter[j]["image"]
                        messages.title = "Error"
                        messages.type = "error"
                        messages.question = false
                        messages.text = text + image
                        messages.addTask(function(){})
                        messages.show()
                    }
                }
            }
        }
    }

    onDisplayChanged: { ms.height = display ? ms.size - 42 : ms.size }
    function sizeChange( choose, width, height ) {
        if ( choose == true ) chooseTag.x = width - width / 3
        else chooseTag.x = width
    }
    function showAnimation() { showTags.running = true }
    function changeDate( date ) {
        stack.push( images )
        menu.selected = 0
        bottomAnimation.running = true
        chooseTag.imageModel = coreFunc.igetImages( "", date )["images"]
        stack.currentItem.model = chooseTag.imageModel
    }
}
