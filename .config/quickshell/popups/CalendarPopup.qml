import qs
import qs.services
import "../components/commons"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

/*!
    \qmltype CalendarPopup
    \inherits BasePopup
    \inqmlmodule popup
    \brief TODO

*/

BasePopup {
    id: root

    ipcTarget: "calendar"
    panelWidth: Settings.calendarPopupWidth
    panelHeight: Settings.calendarPopupHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // ---- header, clock & date ----
        ColumnLayout {
            id: header

            spacing: 4
            Layout.fillWidth: true

            SystemClock {
                id: sysClock

                precision: SystemClock.Minutes
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: Qt.formatTime(sysClock.date, "HH")
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.pixelSize: 50
                    font.bold: true
                }

                Text {
                    text: ":"
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.pixelSize: 50
                    font.bold: true
                    //opacity: 0.
                }

                Text {
                    text: Qt.formatTime(sysClock.date, "mm")
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.pixelSize: 50
                    font.bold: true
                }

            }

            Text {
                text: Qt.formatDate(sysClock.date, "dddd, d MMMM yyyy")
                color: Theme.grvYellow
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.capitalization: Font.Capitalize
            }

        }
        Rectangle {
            color: "transparent"
            height: 8
        }


        // ---- calendar body ----
        ColumnLayout {
            id: body

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Repeater {
                    model: ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.fg1
                        font.family: Theme.fontName
                        font.pixelSize: 11
                        font.bold: true
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.grvYellow 
                opacity: 0.2
                
            }

        

            MonthGrid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 300
                month: sysClock.date.getMonth()
                year: sysClock.date.getFullYear()
                locale: Qt.locale("en_EN")

                delegate: Rectangle {
                    required property date date

                    property bool isToday: date.toDateString() === sysClock.date.toDateString()
                    color:  isToday? Theme.grvYellow : (mouseArea.containsMouse ? Theme.bg1 : "transparent")
                    opacity: isToday ? 0.8 : 1
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: parent.date.getDate()
                        color: {
                            if (parent.date.toDateString() === sysClock.date.toDateString())
                                return Theme.bg0;
                              return parent.date.getMonth() === sysClock.date.getMonth() ? Theme.fg1 : Theme.grvGray || "#665c54";
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: parent.date.toDateString() === sysClock.date.toDateString()
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            // TODO
                            console.log("[CalendarPopup] day clicked: ", parent.date);
                        }
                    }

                }

            }

        }

    }

    Behavior on panelHeight {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }

    }

}
