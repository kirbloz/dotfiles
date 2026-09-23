import ".."
import "../components"
import "../components/effects"
import "../notifications"
import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root

    property bool isOpen: false
    property bool isWindowVisible: false
    property real openProgress: 0 // 0 = pill, 1 = pannello aperto — unica fonte di verità geometrica
    // --- stato pill (era CustomNotification.qml) ---
    property int notifCount: 0
    property bool isPaused: false
    //readonly property int barHeight: 36 // TODO: verifica con la tua bar
    //readonly property int pillHeight: 25
    //readonly property int panelWidth: 340
    //readonly property int panelHeight: 500

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

    // launches service
    NotifsManager {
        id: notifManager
    }

    // --- Polling dunstctl (era CustomNotification.qml) ---
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

    Rectangle {
        //clip: true

        id: morphFrame

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: ((Settings.barHeight - Settings.notifPillHeight) / 2) + (((Settings.barHeight + 8) - (Settings.barHeight - Settings.notifPillHeight) / 2) * root.openProgress)
        anchors.rightMargin: 8 // TODO: allinea al margine reale della pill nella bar
        width: (pillLayout.implicitWidth + 20) + (Settings.notifPanelWidth - (pillLayout.implicitWidth + 20)) * root.openProgress
        height: Settings.notifPillHeight + (Settings.notifPanelHeight - Settings.notifPillHeight) * root.openProgress
        radius: (Settings.notifPillHeight / 2) + ((Theme.radius + 4) - Settings.notifPillHeight / 2) * root.openProgress
        border.width: 1 //(pillHeight / 2) + (3 - pillHeight / 2) * root.openProgress
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
            // --- Contenuto pill ---

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

            // --- Contenuto pannello ---
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
                    onToggled: notifManager.toggleDnd()
                }

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
                                 onClosed: notifManager.removeFromList(notif.id)
    
                            }

                        }

                    }

                }

            }

            // Sensore 1: hitbox del pill chiuso — ferma, mai animata, apre il pannello
            Item {
                id: pillHoverSensor

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: (Settings.barHeight - Settings.notifPillHeight) / 2 // posizione statica del pill a riposo
                anchors.rightMargin: 8
                width: pillLayout.implicitWidth + 20
                height: Settings.notifPillHeight

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) {
                            hoverCloseTimer.stop();
                            hoverOpenTimer.restart();
                        }
                         else {
                hoverOpenTimer.stop();   // fix: annulla l'apertura se te ne vai in tempo
            }
                    }
                }

            }

            // Sensore 2: hitbox del pannello aperto — dimensioni finali fisse, mai animate.
            // Attivo SOLO quando il pannello è (o sta per essere) aperto, altrimenti
            // sarebbe una zona fantasma che apre il pannello anche se ci passi sopra da chiuso.
            Item {
                id: panelHoverSensor

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 8
                width: Settings.notifPanelWidth
                height: Settings.notifPanelHeight
                enabled: root.isOpen // NEW: nessuna hitbox fantasma quando è chiuso

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

            // Click sulla pill: attivo SOLO da chiuso, si disattiva da solo quando il pannello è aperto
            // lasciando passare i click al contenuto (X, clear, DndWidget, notification cards)
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

        function requestClose() {
            if (!panelHover.hovered)
                root.isOpen = false;

        }

        target: "notifications"
    }

    Behavior on openProgress {
        NumberAnimation {
            duration: root.isOpen ? Settings.notifOpenAnimDuration : Settings.notifCloseAnimDuration
            easing.type: root.isOpen ? Easing.OutBack : Easing.InOutQuad
            easing.overshoot: root.isOpen ? 0.8 : 0
        }

    }

}
