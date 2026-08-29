import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."

Rectangle {
    id: tempPill
    implicitWidth: layout.implicitWidth + 24
    implicitHeight: 30
    radius: height / 2
    
    // Logica dei colori (soglia critica a 85°C come nel tuo JSON)
    property int tempValue: 0
    property bool isCritical: tempValue >= 85
    color: isCritical ? "#f38ba8" : Theme.darkgray
    border.color: isCritical ? "#f38ba8" : "transparent"
    border.width: 1

    // 1. Lettura del sensore ogni 5 secondi
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: tempReader.running = true
    }

    Process {
        id: tempReader
        command: ["cat", "/sys/class/hwmon/hwmon5/temp1_input"]
        stdout: SplitParser {
            onRead: data => {
                let rawValue = parseInt(data.trim());
                if (!isNaN(rawValue)) {
                    tempPill.tempValue = Math.round(rawValue / 1000);
                }
            }
        }
    }

    // 2. Interfaccia Visiva
    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "" // Icona termometro
            color: tempPill.isCritical ? "#1e1e1e" : "#fab387"
            font.pixelSize: 14
        }

        Text {
            text: tempPill.tempValue + "°C"
            color: tempPill.isCritical ? "#1e1e1e" : Theme.fg0
            font.pixelSize: 14
            font.bold: true
        }
    }

    // 3. Gestione Click (Dashboard e Btop)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                toggleDashboard.running = true;
            } else if (mouse.button === Qt.RightButton) {
                openBtop.running = true;
            }
        }
    }

    // Comandi eseguiti al click
    Process { 
        id: toggleDashboard
        command: ["qs", "ipc", "call", "dashboard", "toggle"]
    }
    
    Process { 
        id: openBtop
        command: ["kitty", "-e", "btop"] 
    }

    /* Il codice della tua dashboard utilizza già un sistema 
    estremamente robusto: legge continuamente da una Named Pipe 
    (/tmp/qs-dashboard) usando un Process con il comando tail -f.
    Il nostro TemperaturePill fa esattamente l'operazione 
    complementare: quando ci clicchi sopra, esegue un rapido 
    echo 'toggle' > /tmp/qs-dashboard. La dashboard intercetta 
    immediatamente la stringa "toggle" e inverte il suo stato 
    visible, apparendo o scomparendo con l'animazione CRT che hai
    impostato
    */

}
