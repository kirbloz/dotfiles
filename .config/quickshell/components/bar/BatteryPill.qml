import "../.."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: batPill

    property int capacity: 100
    property string batStatus: "Unknown"
    property bool isCharging: batStatus === "Charging" || batStatus === "Full"
    property bool isCritical: capacity <= 20 && !isCharging
    property bool showAlt: false

    implicitHeight: 30
    implicitWidth: layout.implicitWidth + 24
    radius: height / 2
    color: isCritical ? Theme.grvRed : Theme.darkgray
    onIsCriticalChanged: {
        if (!isCritical)
            opacity = 1;

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readBattery.running = true
    }

    Process {
        id: readBattery

        command: ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null) $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)\""]

        stdout: SplitParser {
            onRead: (data) => {
                let parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    batPill.capacity = parseInt(parts[0]);
                    batPill.batStatus = parts[1];
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
                if (batPill.isCharging)
                    return "";

                // Icona in carica
                // Mappa la percentuale (0-100) all'array di 11 icone
                const icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
                let index = Math.floor(batPill.capacity / 10);
                if (index > 10)
                    index = 10;

                if (index < 0)
                    index = 0;

                return icons[index];
            }
            font.pixelSize: 15
            color: batPill.isCritical ? Theme.grvRed : Theme.fg0
        }

        Text {
            text: batPill.showAlt ? batPill.batStatus : (batPill.capacity + "%")
            font.pixelSize: 14
            font.bold: true
            color: batPill.isCritical ? Theme.grvRed : Theme.fg0
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: batPill.showAlt = !batPill.showAlt
    }

    SequentialAnimation on opacity {
        running: batPill.isCritical
        loops: Animation.Infinite

        NumberAnimation {
            to: 0.4
            duration: 500
            easing.type: Easing.Linear
        }

        NumberAnimation {
            to: 1
            duration: 500
            easing.type: Easing.Linear
        }

    }

}
