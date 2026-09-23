import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string netType: "DISCONNECTED"
    // "WIFI" | "ETH" | "DISCONNECTED"
    property string ifName: ""
    property int sigStrength: 0
    property string connectedWifi: ""
    readonly property string tooltipText: {
        let lines = [];
        if (netType === "WIFI") {
            let name = connectedWifi.length > 0 ? connectedWifi : ifName;
            lines.push(name + " # " + sigStrength + "%");
        } else if (netType === "ETH") {
            lines.push("" + ifName);
        } else {
            lines.push("Disconnesso");
        }
        if (netType !== "DISCONNECTED") {
            lines.push("IP: " + deviceIp);
            lines.push("Gateway: " + gatewayIp);
        }
        if (hostname.length > 0)
            lines.push("Host: " + hostname);

        return lines.join("\n");
    }
    property string deviceIp: "N/A"
    property string gatewayIp: "N/A"
    property string hostname: ""

    Process {
        id: statusProcess

        command: ["sh", "-c", "for i in /sys/class/net/*/; do " + "  IF=$(basename $i); " + "  case $IF in lo|docker*|veth*|br-*|virbr*|tailscale*) continue;; esac; " + "  STATE=$(cat /sys/class/net/$IF/operstate 2>/dev/null); " + "  if [ \"$STATE\" = \"up\" ]; then " + "    if [ -d /sys/class/net/$IF/wireless ]; then " + "      SIG=$(awk -v ifc=\"$IF:\" '$1==ifc {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null); " + "      TYPE=WIFI; " + "    else " + "      SIG=100; TYPE=ETH; " + "    fi; " + "    IP=$(ip -4 addr show \"$IF\" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1); " + "    GW=$(ip route show default 2>/dev/null | awk '{print $3; exit}'); " + "    echo \"$TYPE $SIG $IF ${IP:-N/A} ${GW:-N/A}\"; exit; " + "  fi; " + "done; " + "echo \"DISCONNECTED 0 none N/A N/A\""]

        stdout: SplitParser {
            onRead: (data) => {
                const parts = data.trim().split(" ");
                if (parts.length < 5)
                    return ;

                const previousType = root.netType;
                root.netType = parts[0];
                const sig = parseInt(parts[1]);
                root.sigStrength = isNaN(sig) ? 0 : Math.min(sig, 100);
                root.ifName = parts[2];
                root.deviceIp = parts[3];
                root.gatewayIp = parts[4];
                if (root.netType === "WIFI" && previousType !== "WIFI")
                    wifiNameProcess.running = true;
                else if (root.netType !== "WIFI")
                    root.connectedWifi = "";
            }
        }

    }

    Process {
        id: hostnameProcess

        command: ["hostname"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.hostname = data.trim();
            }
        }

    }

    Process {
        id: wifiNameProcess

        command: ["sh", "-c", "iwgetid -r 2>/dev/null"]

        stdout: SplitParser {
            onRead: (data) => {
                return root.connectedWifi = data.trim();
            }
        }

    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

}
