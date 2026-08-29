import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: btPill

    // Stati: OFF, ON, CONNECTED
    property string btStatus: "OFF" 

    // Stile base
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 20
    radius: height / 2
    color: "#171717"
    border.color: "#444444"
    border.width: 1

    // Polling di Bluetoothctl
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readBt.running = true
    }

    Process {
        id: readBt
        // Controlla prima se è acceso, poi se ci sono dispositivi connessi
        command: ["sh", "-c", "if bluetoothctl show | grep -q 'Powered: yes'; then if bluetoothctl info | grep -q 'Connected: yes'; then echo 'CONNECTED'; else echo 'ON'; fi; else echo 'OFF'; fi"]
        stdout: SplitParser {
            onRead: data => {
                btPill.btStatus = data.trim();
            }
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent

        Text {
            text: btPill.btStatus === "OFF" ? " " : ""
            font.pixelSize: 15
            color: {
                if (btPill.btStatus === "CONNECTED") return Theme.grvAqua;
                if (btPill.btStatus === "ON") return Theme.grvBlue;
                return "#888888"; // OFF (Testo sbiadito)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: openBlueman.running = true
    }

    Process {
        id: openBlueman
        command: ["blueman-manager"]
    }
}