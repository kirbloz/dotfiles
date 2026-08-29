import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    // Stato principale — letto via sysfs, leggero, nessun nmcli in loop
    property string netType: "DISCONNECTED"
    // "WIFI" | "ETH" | "DISCONNECTED"
    property string ifName: ""
    property int signalStrength: 0
    // Nome della rete Wi-Fi connessa — via nmcli, ma solo quando serve
    property string connectedWifi: ""
    readonly property string tooltipText: {
        if (netType === "WIFI") {
            let name = connectedWifi.length > 0 ? connectedWifi : ifName;
            return name + " # " + signalStrength + "%";
        }
        if (netType === "ETH")
            return "" + ifName;

        return "Disconnesso";
    }

    Process {
        // appena ti connetti al wifi, chiedi il nome

        id: statusProcess

        command: ["sh", "-c", "for i in /sys/class/net/*/; do " + "  IF=$(basename $i); " + "  case $IF in lo|docker*|veth*|br-*|virbr*|tailscale*) continue;; esac; " + "  STATE=$(cat /sys/class/net/$IF/operstate 2>/dev/null); " + "  if [ \"$STATE\" = \"up\" ]; then " + "    if [ -d /sys/class/net/$IF/wireless ]; then " + "      SIG=$(awk -v ifc=\"$IF:\" '$1==ifc {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null); " + "      echo \"WIFI $SIG $IF\"; exit; " + "    else " + "      echo \"ETH 100 $IF\"; exit; " + "    fi; " + "  fi; " + "done; " + "echo \"DISCONNECTED 0 none\""]

        stdout: SplitParser {
            onRead: (data) => {
                const parts = data.trim().split(" ");
                if (parts.length < 3)
                    return ;

                const previousType = root.netType;
                root.netType = parts[0];
                const sig = parseInt(parts[1]);
                root.signalStrength = isNaN(sig) ? 0 : Math.min(sig, 100);
                root.ifName = parts[2];
                if (root.netType === "WIFI" && previousType !== "WIFI")
                    wifiNameProcess.running = true;
                else if (root.netType !== "WIFI")
                    root.connectedWifi = "";
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
