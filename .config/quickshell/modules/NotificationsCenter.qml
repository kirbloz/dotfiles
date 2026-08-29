import ".."
import "../components"
import "../components/effects"
import "../notifications"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    property bool isOpen: false
    property bool isWindowVisible: false
    readonly property int expandedWidth: 340
    readonly property int expandedHeight: 500

    color: "transparent"
    visible: isWindowVisible
    exclusionMode: ExclusionMode.Ignore
    onIsOpenChanged: {
        if (isOpen) {
            isWindowVisible = true;
            closeTimer.stop();
        } else {
            closeTimer.restart();
        }
    }
    implicitWidth: expandedWidth + 4

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: 35
        right: 0
    }

    Timer {
        id: closeTimer

        interval: 350
        onTriggered: root.isWindowVisible = false
    }

    // launches service
    NotifsManager {
        id: notifManager
    }

    //yellow bar
    Rectangle {
        /*id: rightEdgeAccent
        width: 8
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        color: Theme.grvYellow
        opacity: root.isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }

        }*/

    }

    // draw background
    ExpandingGlowPanel {
        id: panel

        anchors.verticalCenter: parent.verticalCenter
        //anchors.right: rightEdgeAccent.left
        width: 320
        height: 480
        transformOrigin: Item.Right
        expanded: root.isOpen

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header: greeter + quick actions
            // todo: move actions to the right
            RowLayout {
                Greeter {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅖"
                    color: Theme.fgMuted
                    // not working \/\/\/\/
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isOpen = false
                    }

                }

            }

            DndWidget {
                Layout.fillWidth: true
                onToggled: {
                    notifManager.toggleDnd();
                }
            }

            // Separatore Dashed retro
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.grvYellow
                opacity: 0.7
            }

            // Sezione Notifiche
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 13
                }

                Item {
                    Layout.fillWidth: true
                }

                //clear all
                Rectangle {
                    implicitWidth: clearRow.implicitWidth + 16
                    implicitHeight: 24
                    radius: Theme.radius
                    color: clearMouse.containsMouse ? Theme.hover : Theme.bg2
                    border.color: Theme.bg3
                    border.width: 1
                    visible: notifManager.notificationsList.length > 0

                    RowLayout {
                        id: clearRow

                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "󰎟"
                            color: Theme.fg1
                            font.pixelSize: 11
                        }

                    }

                    MouseArea {
                        id: clearMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notifManager.clearHistory()
                    }

                }

            }

            // dunst history
            ScrollView {
                id: notifScroll

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    id: notifList

                    width: notifScroll.width
                    spacing: 8

                    Text {
                        text: "Nessuna notifica presente"
                        color: Theme.fgMuted
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        Layout.alignment: Qt.AlignHCenter
                        visible: notifManager.notificationsList.length === 0
                    }

                    Repeater {
                        model: notifManager.notificationsList

                        NotificationCard {
                            Layout.fillWidth: true
                            notif: modelData
                        }

                    }

                }

            }

        }

    }

    // IPC Server nativo
    IpcHandler {
        function toggle() {
            root.isOpen = !root.isOpen;
        }

        function open() {
            root.isOpen = true;
        }

        function close() {
            root.isOpen = false;
        }

        target: "notifications"
    }

}
