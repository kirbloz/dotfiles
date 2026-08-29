import QtQuick
import Quickshell
import "../.."

Rectangle {
    color: Theme.darkgray
    
    implicitHeight: 30
    implicitWidth: clockText.width + 24
    radius: height / 2  

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Theme.fg0 
        font.pixelSize: 14 
        font.family: "Fira Sans Semibold" // Font principale[cite: 2]
        
        // Quickshell non ha un modulo orologio nativo out-of-the-box in puro QML standard, 
        // usiamo un Timer per aggiornare l'ora
        Timer {
            interval: 60000 // interval: 60[cite: 5]
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                // Formatta la data simulando il tuo %H:%M %a %d %b
                clockText.text = Qt.formatDateTime(new Date(), "hh:mm   ddd dd MMM")
            }
        }
    }
}