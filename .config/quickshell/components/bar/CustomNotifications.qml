import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."

Rectangle {
    id: root
    property int notifCount: 0
    property bool isPaused: false
    color: Theme.grvYellow 
    radius: height/2
    implicitHeight: 25
    implicitWidth: layout.implicitWidth + 20 // Padding laterale dinamico
    
    signal openNotifCenterRequested()
    
    // Lettura dei dati "interval": 2)
    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateState.running = true
    }

    // Interroga dunstctl. Otteniamo le due informazioni separate da uno spazio per pulizia.
    Process {
        id: updateState
        command: ["sh", "-c", "echo \"$(dunstctl count history 2>/dev/null) $(dunstctl is-paused 2>/dev/null)\""]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    let count = parseInt(parts[0]);
                    root.notifCount = isNaN(count) ? 0 : count;
                    root.isPaused = (parts[1] === "true");
                }
            }
        }
    }

    // 4. Processi in risposta ai Click
    Process { 
        id: toggleNotifications
        command: ["qs", "ipc", "call", "notifications", "toggle"] 
    }
    
    Process { 
        id: toggleDnd 
        command: ["dunstctl", "set-paused", "toggle"]
        onExited: updateState.running = true // Aggiorna l'icona immediatamente
    }
    
    Process { 
        id: clearHistory 
        command: ["dunstctl", "history-clear"]
        onExited: updateState.running = true // Aggiorna il counter immediatamente
    }

    // 5. Interfaccia Visiva
    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        // Gestione Logica Icone (fedele a "format-icons")
        Text {
            text: {
                if (root.isPaused) {
                    return root.notifCount > 0 ? "󰂛" : "󰪑"; // dnd-notification : dnd-none
                } else {
                    return root.notifCount > 0 ? "󱅫" : "󰂜"; // notification : none
                }
            }
            font.family: "NotoSansMono Nerd Font"
            font.pixelSize: 18
            color: "#171717" // Il tuo @backgroundlight per fare contrasto sul giallo
        }

        // Testo del contatore (visibile solo se ci sono notifiche, come il tuo "format-none": "{icon}")
        Text {
            visible: root.notifCount > 0
            text: root.notifCount.toString()
            font.family: "NotoSansMono Nerd Font"
            font.pixelSize: 16
            font.bold: true
            color: "#171717"
        }
    }

    // 6. Gestione Mouse
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
               toggleNotifications.running = true;
            } else if (mouse.button === Qt.RightButton) {
                toggleDnd.running = true;
            } else if (mouse.button === Qt.MiddleButton) {
                clearHistory.running = true;
            }
        }
    }
}