import ".."
import "../components"
import "../components/dashboard"
import "../components/effects"
import "../components/commons"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: dashRoot
    property bool isOpen: false
    property bool isWindowVisible: false
    readonly property int expandedWidth: 400
    readonly property int expandedHeight: 350

color: "transparent"
    implicitWidth: expandedWidth +28
    implicitHeight: expandedHeight+28
    
   // visible: isOpen || morphBox.width > 90
    visible: isWindowVisible
    //exclusionMode: ExclusionMode.Ignore
    onIsOpenChanged: {
        if (isOpen) {
            isWindowVisible = true;
            closeTimer.stop();
        } else {
            closeTimer.restart();
        }
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: 8
        right: 15
    }

    Timer {
        id: closeTimer

        interval: 350
        onTriggered: dashRoot.isWindowVisible = false
    }


    // launches service
    SystemStats {
        id: stats
    }

    ExpandingGlowPanel {
        id: panel
        width: expandedWidth
        height: expandedHeight
        transformOrigin: Item.Top
        expanded: dashRoot.isOpen
        

        ColumnLayout {
            id:mainLayout
            anchors.fill:parent
            anchors.margins: 14
            spacing: 10
           Header { title: "System Dashboard"; onCloseRequested: dashRoot.isOpen = false }

            StatBar {
                label: "CPU"
                value: stats.cpuUsage
                barColor: Theme.grvYellow
            }

            StatBar {
                label: "RAM"
                value: stats.ramUsage
                valueText: stats.ramLabel
                barColor: Theme.grvAqua
            }

            StatBar {
                label: "Disk /"
                value: stats.diskUsage
                valueText: stats.diskLabel
                barColor: Theme.grvRed
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.grvYellow
                opacity: 0.4
            }

            NetworkStatsRow { rx: stats.netRxKBs; tx: stats.netTxKBs }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                PowerProfileMenu {}
                PowerMenu{}
                
                /*Item {
                    Layout.fillHeight: true
                }*/

            }

        }

    }

    IpcHandler {
    target: "dashboard"
    function toggle(): void { dashRoot.isOpen = !dashRoot.isOpen }
    function open(): void { dashRoot.isOpen = true }
    function close(): void { dashRoot.isOpen = false }
    }

}
