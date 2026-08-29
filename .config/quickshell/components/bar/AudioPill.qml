import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: audioPill

    property int volume: 0
    property bool isMuted: false

    // Stile base
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    radius: height / 2
    color: "#171717"
    border.color: "#444444"
    border.width: 1

    // Lettura dello stato via WirePlumber (PipeWire)
    Timer {
        interval: 1000 // Aggiorna ogni secondo
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readAudio.running = true
    }

    Process {
        id: readAudio
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                // Esempio output: "Volume: 0.45" oppure "Volume: 0.45 [MUTED]"
                let text = data.trim();
                audioPill.isMuted = text.includes("[MUTED]");
                
                let volMatch = text.match(/Volume:\s+([0-9.]+)/);
                if (volMatch && volMatch.length > 1) {
                    audioPill.volume = Math.round(parseFloat(volMatch[1]) * 100);
                }
            }
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        // Icona Dinamica
        Text {
            text: {
                if (audioPill.isMuted) return "";
                if (audioPill.volume > 66) return "";
                if (audioPill.volume > 33) return "";
                return "";
            }
            font.pixelSize: 15
            color: audioPill.isMuted ? "#888888" : "white"
        }

        // Testo Volume
        Text {
            text: audioPill.volume + "%"
            font.pixelSize: 14
            color: audioPill.isMuted ? "#888888" : "white"
        }
    }

    // Interazione
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: openPavucontrol.running = true
    }

    Process {
        id: openPavucontrol
        command: ["pavucontrol"]
    }
}