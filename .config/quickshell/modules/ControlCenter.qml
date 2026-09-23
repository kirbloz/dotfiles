import "../components"
import "../components/commons"
import "../components/effects"
import "../components/controlcenter"
import "../notifications"
import "../services"
import ".."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    readonly property int expandedWidth: 400
    readonly property int expandedHeight: mainLayout.implicitHeight + 28
    color: "transparent"

    anchor.item: ControlCenterService.anchorItem
    anchor.rect.x: ControlCenterService.anchorItem
        ? ControlCenterService.anchorItem.width - expandedWidth / 1.5
        : 0
    anchor.rect.y: ControlCenterService.anchorItem
        ? ControlCenterService.anchorItem.height + 8
        : 0

    implicitWidth: expandedWidth +28
    implicitHeight: expandedHeight +28

    Connections {
        target: ControlCenterService
        function onOpenChanged() {
            if (ControlCenterService.open) {
                root.visible = true
                growTimer.restart()
            } else {
                panel.expanded = false
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: growTimer
        interval: 10
        onTriggered: panel.expanded = true
    }

    Timer {
        id: hideTimer
        interval: 380
        onTriggered: root.visible = false
    }

    ExpandingGlowPanel {
        id: panel
        width: expandedWidth
        height: expandedHeight
        transformOrigin: Item.Top

        ColumnLayout {
            id: mainLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            spacing: 10

            Header { title: "Control Center :)"; onCloseRequested: ControlCenterService.close() }

            QuickTogglesGrid {
               
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.grvYellow
                opacity: 0.3
            }

            BacklightWidget {
                Layout.fillWidth: true
            }

            VolumeWidget {
                Layout.fillWidth: true
            }

            MprisWidget {
                Layout.fillWidth: true
            }
           
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.grvYellow
                opacity: 0.3
            }
            ScreenRecWidget {
                Layout.fillWidth: true
            }
        }
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void {
            if (ControlCenterService.anchorItem)
                ControlCenterService.toggleFrom(ControlCenterService.anchorItem)
        }
        function open(): void {
            if (ControlCenterService.anchorItem)
                ControlCenterService.openFrom(ControlCenterService.anchorItem)
        }
        function close(): void {
            ControlCenterService.close()
        }
    }
}
