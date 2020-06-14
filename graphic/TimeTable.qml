import QtQuick 2.9
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors.fill: parent

    property var func: root.func
    property int bettaTesting: 1
    property int switchDate: 0
    property int globalMonth: 0

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#18191D"

        Item {
            width: parent.width
            height: 42

            Image {
                width: 32
                height: 32
                y: 5
                x: 5
                source: "qrc:/images/left.svg"
                sourceSize: Qt.size( 64, 64 )

                ColorOverlay {
                    id: colorLeft
                    anchors.fill: parent
                    source: parent
                    color: "#808080"
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if ( containsMouse ) colorLeft.color = "white"
                        else colorLeft.color = "#808080"
                    }
                    onClicked: {
                        switchDate = switchDate - 1
                        grid.setDate( switchDate )
                    }
                }
            }

            Text {
                id: nowMonth
                font.pointSize: 16
                color: "white"
                smooth: true
                text: ""
                anchors.centerIn: parent
                font.letterSpacing: 1.5
            }

            Image {
                width: 32
                height: 32
                anchors.right: parent.right
                x: parent.width - 38
                y: 5
                source: "qrc:/images/right.svg"
                sourceSize: Qt.size( 64, 64 )

                ColorOverlay {
                    id: colorRight
                    anchors.fill: parent
                    source: parent
                    color: "#808080"
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if ( containsMouse ) colorRight.color = "white"
                        else colorRight.color = "#808080"
                    }
                    onClicked: {
                        switchDate = switchDate + 1
                        grid.setDate( switchDate )
                    }
                }
            }
        }

        GridView {
            id: grid
            property int selected: 0
            width: parent.width
            height: parent.height - 42
            y: 42
            cellWidth: grid.width / 7 - 1
            cellHeight: grid.height / 7
            focus: true
            interactive: false
            model: []
            delegate: TableItem {
                active: modelData["active"]
                bettaTesting: root.bettaTesting
                is_weekDay: modelData["is_weekDay"]
                number: modelData["number"]
                wd: grid.cellWidth - 1
                hg: grid.cellHeight - 1
                onClicked: {
                    if ( modelData["is_weekDay"] == 0 && modelData["active"] == 1 ) {
                        if ( grid.selected != index ) {
                            grid.currentIndex = index
                            let item = grid.currentItem
                            item.select()
                            grid.currentIndex = grid.selected
                            item = grid.currentItem
                            item.deselect()
                            grid.selected = index
                        } else root.func.change = 1
                        let currentYear = Qt.formatDateTime( new Date(), "yyyy" )
                        let currentMonth= globalMonth < 10 ? "0" + globalMonth.toString() : globalMonth.toString()
                        let day = parseInt(modelData["number"]) < 10 ? "0" + modelData["number"] : modelData["number"]
                        root.func.date = currentYear + "-" + currentMonth + "-" + day
                        root.func.running = true
                    }
                }
            }
            Component.onCompleted: setDate(0)

            function conventer( mounth ) {
                if ( mounth > 12 ) {
                    return conventer( mounth - 12 )
                } else if ( mounth < 0 ) {
                    return conventer( mounth + 12 )
                } else return mounth
            }

            function setDate( month ) { // please set from 0. 0 is current month
                let model = []
                let currentYear = Qt.formatDateTime( new Date(), "yyyy" )
                let currentMonth= Qt.formatDateTime( new Date(), "MM" )
                switch ( conventer( parseInt(currentMonth) + month ) ) {
                    case 0: nowMonth.text = "Декабрь"; break
                    case 1: nowMonth.text = "Январь"; break
                    case 2: nowMonth.text = "Февраль"; break
                    case 3: nowMonth.text = "Март"; break
                    case 4: nowMonth.text = "Апрель"; break
                    case 5: nowMonth.text = "Май"; break
                    case 6: nowMonth.text = "Июнь"; break
                    case 7: nowMonth.text = "Июль"; break
                    case 8: nowMonth.text = "Август"; break
                    case 9: nowMonth.text = "Сентябрь"; break
                    case 10:nowMonth.text = "Октябрь"; break
                    case 11:nowMonth.text = "Ноябрь"; break
                    case 12:nowMonth.text = "Декабрь"; break
                }
                globalMonth = conventer( parseInt(currentMonth) + month )
                let firstMonthDay = new Date( currentYear, parseInt(currentMonth) - ( 1 - month ), 0, 1 )
                let lastMonthDay  = new Date( currentYear, parseInt(currentMonth) + month, 0, 1 )

                let firstDay = new Date( firstMonthDay.getTime() - (((firstMonthDay.getDay() === Locale.Sunday) ? Qt.Sunday : firstMonthDay.getDay()) - 1) * 86400000 )
                if( firstMonthDay == Qt.Sunday)
                    firstDay = new Date(firstDay.getTime() - 86400000);

                let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                for ( let i = 0; i < 7; i++ ) {
                    let meta = {
                        "active"    : 1,
                        "number"    : days[i],
                        "is_weekDay": 1
                    }
                    model.push( meta )
                }
                for( let i = 0; i < 42; i++ ) {
                    let checkDay = new Date(firstDay.getTime() + i*86400000)
                    let meta = {
                        "active" : checkDay.getTime() > firstMonthDay.getTime() && checkDay.getTime() <= lastMonthDay.getTime() ? 1 : 0,
                        "number" : Qt.formatDateTime( checkDay, "dd" )[0] == "0" ? Qt.formatDateTime( checkDay, "dd" )[1] : Qt.formatDateTime( checkDay, "dd" ),
                        "is_weekDay": 0
                    }
                    model.push( meta )
                }
                grid.model = model
            }
        }
    }

    function deselect() {
        for ( let i = 0; i < grid.model.length; i++ ) {
            grid.currentIndex = grid.selected
            let item = grid.currentItem
            item.deselect()
            grid.selected = 0
        }
    }
}
