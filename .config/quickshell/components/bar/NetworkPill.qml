import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."

/*
Per mantenere le prestazioni del tuo sistema al massimo 
(esattamente come abbiamo fatto per la temperatura e 
la batteria), possiamo leggere lo stato della rete 
leggendo direttamente il kernel di Linux 
(i file /sys/class/net e /proc/net/wireless). 
Questo ci dà il nome dell'interfaccia e la percentuale
del Wi-Fi in una frazione di millisecondo.
*/

Rectangle {
    id: netPill

    // 1. Stati della Rete
    property string netType: "DISCONNECTED" // Può essere "WIFI", "ETH" o "DISCONNECTED"
    property string ifName: ""
    property int signalStrength: 0

    // 2. Stile e Colori (Base: @backgroundlight)
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    radius: height / 2
    
    // Diventa rosso se disconnesso (il tuo @grv-bright-red)
    color: netType === "DISCONNECTED" ? Theme.grvRed : Theme.darkgray
    border.color: netType === "DISCONNECTED" ? Theme.grvRed : "#444444"
    border.width: 1

    // 3. Lettura Leggera e Veloce (Senza usare nmcli!)
    Timer {
        interval: 3000 // Aggiorna ogni 3 secondi
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readNetwork.running = true
    }

    Process {
        id: readNetwork
        // Questo script bash legge il kernel: controlla prima il Wi-Fi, poi l'Ethernet
        command: ["sh", "-c", "WIFI=$(ls /sys/class/net/ | grep -e '^wl' | head -n 1); ETH=$(ls /sys/class/net/ | grep -e '^en' | head -n 1); if [ -n \"$WIFI\" ] && grep -q 'up' /sys/class/net/$WIFI/operstate 2>/dev/null; then SIG=$(awk 'NR==3 {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null); echo \"WIFI $SIG $WIFI\"; elif [ -n \"$ETH\" ] && grep -q 'up' /sys/class/net/$ETH/operstate 2>/dev/null; then echo \"ETH 100 $ETH\"; else echo \"DISCONNECTED 0 none\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ");
                if (parts.length >= 3) {
                    netPill.netType = parts[0];
                    let sig = parseInt(parts[1]);
                    netPill.signalStrength = isNaN(sig) ? 0 : sig;
                    
                    // Impedisce percentuali oltre il 100%
                    if (netPill.signalStrength > 100) netPill.signalStrength = 100;
                    
                    netPill.ifName = parts[2];
                }
            }
        }
    }

    // 4. Interfaccia Visiva
    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        Text {
            // Seleziona l'icona in base al tipo di connessione
            text: {
                if (netPill.netType === "WIFI") return "";
                if (netPill.netType === "ETH") return "";
                return "⚠"; // Disconnesso
            }
            font.pixelSize: 15
            // Testo scuro se lo sfondo diventa rosso
            color: netPill.netType === "DISCONNECTED" ? "#171717" : "white"
        }

        Text {
            // Mostra i dati formattati come nel tuo JSON
            text: {
                if (netPill.netType === "WIFI") return netPill.signalStrength + "%";
                if (netPill.netType === "ETH") return netPill.ifName;
                return "Disconnected";
            }
            font.pixelSize: 14
            color: netPill.netType === "DISCONNECTED" ? "#171717" : "white"
        }
    }

    // 5. Apertura di nm-connection-editor al click
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: openNetworkManager.running = true
    }

    Process {
        id: openNetworkManager
        command: ["nm-connection-editor"]
    }
}