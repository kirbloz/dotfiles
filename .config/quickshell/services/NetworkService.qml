pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

import "../scripts/nmcli.js" as Nmcli

/*
 * NetworkService handles status and runs command. 
 * components are view only
 * data is retrieved via nmcli API and parsed by nmcli.js; 
 * service exposes information to other components 
 */

 // FIXME this service has many Processes and is heavier than others

Singleton {
    id: root

    property string netType: "DISCONNECTED"
    property string connectedWifi: ""
    property int sigStrength: 0
    property string ifName: ""
    property string deviceIp: "N/A"
    property string gatewayIp: "N/A"
    property string hostname: ""
    property bool wifiEnabled: true
    property var networks: []  // [{ ssid, strength, inUse, secured }]
    property bool connecting: false
    property string connectError: ""

    // nmcli monitor notifies state changes
    // for wifi signal information, an explicit read is needed
    readonly property int sigRefreshMs: 100000


    readonly property string tooltipText: {
        let lines = [];
        if (netType === "WIFI") {
            let name = connectedWifi.length > 0 ? connectedWifi : ifName;
            lines.push(name + " (" + sigStrength + "%)");
        } else if (netType === "ETH") {
            lines.push("Ethernet: " + ifName);
        } else {
            lines.push("Disconnected");
        }
        if (netType !== "DISCONNECTED") {
            lines.push("IP: " + deviceIp);
            lines.push("Gateway: " + gatewayIp);
        }
        if (hostname.length > 0)
            lines.push("Host: " + hostname);
        return lines.join("\n");
    }

    signal connectFinished(bool success)

    function setWifiEnabled(enabled) {
        _run(radioSetProc, ["nmcli", "radio", "wifi", enabled ? "on" : "off"]);
    }

    function scanWifi() {
        if (wifiEnabled)
            _listWifi(true);
    }

    function connectToWifi(ssid, password) {
        if (connecting)
            return;
        connectError = "";
        connecting = true;
        const cmd = ["nmcli", "device", "wifi", "connect", ssid];
        if (password && password.length > 0)
            cmd.push("password", password);
        _run(connectProc, cmd);
    }

    function disconnectWifi() {
        if (ifName !== "")
            _run(disconnectProc, ["nmcli", "device", "disconnect", ifName]);
    }

    function clearConnectError() {
        connectError = "";
    }

    function refresh() {
        refreshDebounce.restart();
    }

    // ── Interno ───────────────────────────────────────────────────────────
    // `running = true` su un Process già attivo è un no-op: lo evitiamo esplicitamente.
    function _run(proc, command) {
        if (proc.running)
            return false;
        if (command)
            proc.command = command;
        proc.running = true;
        return true;
    }

    function _listWifi(rescan) {
        _run(wifiListProc, ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", rescan ? "auto" : "no"]);
    }

    function _applyDevices(text) {
        const dev = Nmcli.activeDevice(Nmcli.parseDevices(text));
        if (!dev) {
            netType = "DISCONNECTED";
            connectedWifi = "";
            sigStrength = 0;
            ifName = "";
            deviceIp = "N/A";
            gatewayIp = "N/A";
        } else {
            ifName = dev.device;
            if (dev.type === "wifi") {
                netType = "WIFI";
                connectedWifi = dev.connection;
                _run(signalProc);
            } else {
                netType = "ETH";
                connectedWifi = "";
                sigStrength = 100;
            }
            _run(ipProc, ["nmcli", "-t", "-f", "IP4.ADDRESS,IP4.GATEWAY", "device", "show", dev.device]);
        }
        if (wifiEnabled)
            _listWifi(false);
    }

    Component.onCompleted: _run(radioReadProc)

    // Pipeline di refresh: radio -> stato device -> (ip, segnale, lista reti)
    Process {
        id: radioReadProc

        command: ["nmcli", "radio", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = (this.text.trim() === "enabled");
                if (!root.wifiEnabled)
                    root.networks = [];
                root._run(stateProc);
            }
        }
    }

    Process {
        id: stateProc

        command: ["nmcli", "-t", "-f", "TYPE,DEVICE,STATE,CONNECTION", "device"]

        stdout: StdioCollector {
            onStreamFinished: root._applyDevices(this.text)
        }
    }

    Process {
        id: ipProc

        stdout: StdioCollector {
            onStreamFinished: {
                const r = Nmcli.parseIp4(this.text);
                root.deviceIp = r.ip;
                root.gatewayIp = r.gateway;
            }
        }
    }

    Process {
        id: signalProc

        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi", "list", "--rescan", "no"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.netType === "WIFI")
                    root.sigStrength = Nmcli.parseInUseSignal(this.text);
            }
        }
    }

    Process {
        id: wifiListProc

        stdout: StdioCollector {
            onStreamFinished: root.networks = Nmcli.parseWifiList(this.text)
        }
    }

    Process {
        id: radioSetProc

        onExited: root.refresh()
    }

    Process {
        id: connectProc

        stderr: StdioCollector {
            onStreamFinished: {
                const msg = Nmcli.cleanError(this.text);
                if (msg !== "")
                    root.connectError = msg;
            }
        }

        onExited: (code, exitStatus) => {
            root.connecting = false;
            if (code !== 0 && root.connectError === "")
                root.connectError = "Connessione fallita";
            root.connectFinished(code === 0);
            root.refresh();
        }
    }

    Process {
        id: disconnectProc

        onExited: root.refresh()
    }

    Process {
        id: hostnameProc

        command: ["hostname"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.hostname = this.text.trim()
        }
    }

    // event listener
    Process {
        id: netMonitor

        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: root.refresh()
        }
    }

    Timer {
        id: refreshDebounce

        interval: 2000
        onTriggered: root._run(radioReadProc)
    }
  
    // signal
    Timer {
        interval: root.sigRefreshMs
        repeat: true
        running: root.netType === "WIFI" && tooltipText.show 
        onTriggered: root._run(signalProc)
    }
   

}
