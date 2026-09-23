import "../.."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: netPill

    property string netType: "DISCONNECTED" //  "WIFI", "ETH" o "DISCONNECTED"
    property string ifName: ""
    property int sigStrength: 0
    property string deviceIp: "N/A"
    property string gatewayIp: "N/A"
    property string hostname: ""

    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 24
    radius: height / 2
    color: netType === "DISCONNECTED" ? Theme.grvRed : Theme.darkgray
    border.color: netType === "DISCONNECTED" ? Theme.grvRed : "#444444"
    border.width: 1

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readNetwork.running = true
    }

    Process {
        id: readNetwork

        command: ["sh", "-c", "WIFI=$(ls /sys/class/net/ | grep -e '^wl' | head -n 1); " + "ETH=$(ls /sys/class/net/ | grep -e '^en' | head -n 1); " + "if [ -n \"$WIFI\" ] && grep -q 'up' /sys/class/net/$WIFI/operstate 2>/dev/null; then " + " IFACE=$WIFI; TYPE=WIFI; " + " SIG=$(awk 'NR==3 {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null); " + "elif [ -n \"$ETH\" ] && grep -q 'up' /sys/class/net/$ETH/operstate 2>/dev/null; then " + " IFACE=$ETH; TYPE=ETH; SIG=100; " + "else IFACE=none; TYPE=DISCONNECTED; SIG=0; fi; " + "IP=$(ip -4 addr show \"$IFACE\" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1); " + "GW=$(ip route show default 2>/dev/null | awk '{print $3; exit}'); " + "HOST=$(hostname); " + "echo \"$TYPE $SIG $IFACE ${IP:-N/A} ${GW:-N/A} $HOST\""]

        stdout: SplitParser {
            onRead: (data) => {
                let parts = data.trim().split(" ");
                if (parts.length >= 6) {
                    netPill.netType = parts[0];
                    let sig = parseInt(parts[1]);
                    netPill.signalStrength = isNaN(sig) ? 0 : sig;
                    if (netPill.signalStrength > 100)
                        netPill.signalStrength = 100;

                    netPill.ifName = parts[2];
                    netPill.deviceIp = parts[3];
                    netPill.gatewayIp = parts[4];
                    netPill.hostname = parts.slice(5).join(" "); // safe se l'hostname avesse spazi
                }
            }
        }

    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: {
                if (netPill.netType === "WIFI")
                    return "";

                if (netPill.netType === "ETH")
                    return "";

                return "⚠"; // Disconnesso
            }
            font.pixelSize: 15
            color: netPill.netType === "DISCONNECTED" ? "#171717" : "white"
        }

        Text {
            text: {
                if (netPill.netType === "WIFI")
                    return netPill.sigStrength + "%";

                if (netPill.netType === "ETH")
                    return netPill.ifName;

                return "Disconnected";
            }
            font.pixelSize: 14
            color: netPill.netType === "DISCONNECTED" ? "#171717" : "white"
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: openNetworkManager.running = true
         onEntered: tooltipShowTimer.restart()
        onExited: {
            tooltipShowTimer.stop();
            tooltip.visible = false;
        }
    }

    Timer {
        id: tooltipShowTimer
        interval: 400          // evita il tooltip su semplice passaggio veloce del mouse
        onTriggered: tooltip.visible = true
    }

    Process {
        id: openNetworkManager

        command: ["nm-connection-editor"]
    }

}
