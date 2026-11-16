import qs
import qs.services
import "../components"
import "../components/effects"
import "../notifications"
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

/*!
    \qmltype NotificationsCenter
    \inherits PanelWindow
    \inqmlmodule modules
    \brief TODO
*/

PanelWindow {
    id: root

    // ---- panel status ----
    property bool isOpen: false
    property bool isWindowVisible: false
    /* \qmlproperty real NotificationsCenter::openProgress
        controls graphical status, 0 = pill and 1 = expanded */
    property real openProgress: 0
    // --- notif manager status ---
    property int notifCount: 0
    property bool isPaused: false

    // ---- geometry ----
    color: "transparent"
    visible: isWindowVisible
    exclusionMode: ExclusionMode.Ignore
    onIsOpenChanged: {
        openProgress = isOpen ? 1 : 0;
        if (isOpen) {
            isWindowVisible = true;
            closeTimer.stop();
        } else {
            closeTimer.restart();
        }
    }
    implicitWidth: Settings.notifPanelWidth + 4 + 40

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: Settings.notifPillHeight + 6
        right: 0
    }

    Timer {
        id: closeTimer

        interval: Settings.notifOpenAnimDuration
        onTriggered: root.isWindowVisible = false
    }

    // ---- service ----
    // uses singleton NotifsManager

    // --- polling dunstctl ---
    Timer {
        id: refreshTimer

        interval: Settings.notifPollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateState.running = true
    }

    Process {
        id: updateState

        command: ["sh", "-c", "echo \"$(dunstctl count history 2>/dev/null) $(dunstctl is-paused 2>/dev/null)\""]

        stdout: SplitParser {
            onRead: (data) => {
                let parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    let count = parseInt(parts[0]);
                    root.notifCount = isNaN(count) ? 0 : count;
                    root.isPaused = (parts[1] === "true");
                }
            }
        }

    }

    Process {
        id: toggleDnd

        command: ["dunstctl", "set-paused", "toggle"]
        onExited: updateState.running = true
    }

    Process {
        id: clearHistory

        command: ["dunstctl", "history-clear"]
        onExited: updateState.running = true
    }

    // ---- view ----
    Rectangle {
        // TODO change the id
        id: morphFrame

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: ((Settings.barHeight - Settings.notifPillHeight) / 2) + (((Settings.barHeight + 8) - (Settings.barHeight - Settings.notifPillHeight) / 2) * root.openProgress)
        anchors.rightMargin: 8
        width: (pillLayout.implicitWidth + 20) + (Settings.notifPanelWidth - (pillLayout.implicitWidth + 20)) * root.openProgress
        height: Settings.notifPillHeight + (Settings.notifPanelHeight - Settings.notifPillHeight) * root.openProgress
        radius: (Settings.notifPillHeight / 2) + ((Theme.radius + 4) - Settings.notifPillHeight / 2) * root.openProgress
        border.width: 1
        color: Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.9)
        border.color: Theme.grvYellow

        Rectangle {
            id: glowSource

            anchors.fill: parent
            color: "transparent"
            border.color: Theme.grvYellow
            border.width: 1
            radius: morphFrame.radius
            visible: false
        }

        MultiEffect {
            source: glowSource
            anchors.fill: glowSource
            blurEnabled: true
            blurMax: 32
            blur: 0.8
            autoPaddingEnabled: true
        }

        Item {
            id: clippedContent

            anchors.fill: parent
            clip: true

            CrtScanlines {
                anchors.fill: parent
                anchors.margins: 2
                opacity: root.openProgress
            }

            // ---- pill content ----
            // TODO move this to WidgetBase
            RowLayout {
                id: pillLayout

                anchors.centerIn: parent
                spacing: 6
                opacity: Math.max(0, 1 - root.openProgress * 1.6)
                visible: opacity > 0.01

                Text {
                    text: root.isPaused ? (root.notifCount > 0 ? "󰂛" : "󰪑") : (root.notifCount > 0 ? "󱅫" : "󰂜")
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 18
                    color: "#171717"
                }

                Text {
                    visible: root.notifCount > 0
                    text: root.notifCount.toString()
                    font.family: "NotoSansMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#171717"
                }

            }

            // ---- panel content ----
            ColumnLayout {
                id: panelContent

                anchors.fill: parent
                anchors.margins: 14
                spacing: 10
                opacity: Math.max(0, (root.openProgress - 0.45) / 0.55)
                visible: opacity > 0.01

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
                    onToggled: NotifsManager.toggleDnd()
                }

                // separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.grvYellow
                    opacity: 0.7
                }

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

                    Rectangle {
                        implicitWidth: clearRow.implicitWidth + 16
                        implicitHeight: 24
                        radius: Theme.radius
                        color: clearMouse.containsMouse ? Theme.hover : Theme.bg2
                        border.color: Theme.bg3
                        border.width: 1
                        visible: NotifsManager.notificationsList.length > 0

                        // ---- clear notifs row ----
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
                            onClicked: NotifsManager.clearHistory()
                        }

                    }

                }

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
                            text: "No notifications"
                            color: Theme.fgMuted
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                            Layout.alignment: Qt.AlignHCenter
                            visible: NotifsManager.notificationsList.length === 0
                        }

                        Repeater {
                            model: NotifsManager.notificationsList

                            NotificationCard {
                                Layout.fillWidth: true
                                notif: modelData
                                onClosed: NotifsManager.removeFromList(notif.id)
                            }

                        }

                    }

                }

            }

            // ---- closed pill hitbox ----
            Item {
                id: pillHoverSensor

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: (Settings.barHeight - Settings.notifPillHeight) / 2
                anchors.rightMargin: 8
                width: pillLayout.implicitWidth + 20
                height: Settings.notifPillHeight

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) {
                            hoverCloseTimer.stop();
                            hoverOpenTimer.restart();
                        } else {
                            hoverOpenTimer.stop();
                        }
                    }
                }

            }

            // ---- open panel hitbox ----
            // active only when panel is fully open or opening
            Item {
                id: panelHoverSensor

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 8
                width: Settings.notifPanelWidth
                height: Settings.notifPanelHeight
                enabled: root.isOpen 

                HoverHandler {
                    id: panelHover

                    enabled: panelHoverSensor.enabled
                    onHoveredChanged: {
                        if (hovered)
                            hoverCloseTimer.stop();
                        else
                            hoverCloseTimer.restart();
                    }
                }

            }

            // click on pill: active only when panel is closed; if not active lets clicks thru to be handled by content children
            MouseArea {
                id: pillClickArea

                anchors.fill: parent
                enabled: !root.isOpen
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton)
                        root.isOpen = true;
                    else if (mouse.button === Qt.RightButton)
                        toggleDnd.running = true;
                    else if (mouse.button === Qt.MiddleButton)
                        clearHistory.running = true;
                }
            }

        }

    }

    Timer {
        id: hoverOpenTimer

        interval: Settings.notifHoverOpenDelay
        onTriggered: root.isOpen = true
    }

    Timer {
        id: hoverCloseTimer

        interval: Settings.notifHoverCloseDelay
        onTriggered: root.isOpen = false
    }

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

        function requestClose() {
            if (!panelHover.hovered)
                root.isOpen = false;

        }

        target: "notifications"
    }

    function toggle() {
            root.isOpen = !root.isOpen;
        }

        function open() {
            root.isOpen = true;
        }

        function close() {
            root.isOpen = false;
        }

        function requestClose() {
            if (!panelHover.hovered)
                root.isOpen = false;

        }

    Behavior on openProgress {
        NumberAnimation {
            duration: root.isOpen ? Settings.notifOpenAnimDuration : Settings.notifCloseAnimDuration
            easing.type: root.isOpen ? Easing.OutBack : Easing.InOutQuad
            easing.overshoot: root.isOpen ? 0.8 : 0
        }

    }

}
