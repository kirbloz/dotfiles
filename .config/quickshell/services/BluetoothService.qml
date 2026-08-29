import QtQuick
import Quickshell
import Quickshell.Bluetooth
pragma Singleton

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property var connectedDevices: Bluetooth.devices
    readonly property int connectionCount: connectedDevices ? connectedDevices.values.length : 0
    readonly property bool hasConnection: connectionCount > 0
    readonly property string status: !powered ? "OFF" : (hasConnection ? "CONNECTED" : "ON")
    readonly property string primaryDeviceName: hasConnection ? connectedDevices.values[0].name : ""

    readonly property string tooltipText: {
        if (!powered)
            return "Bluetooth spento";

        if (!hasConnection)
            return (adapter ? adapter.name : "Bluetooth") + "\n0 connessi";

        let lines = [adapter.name, connectionCount + " connessi"];
        for (const dev of connectedDevices.values) lines.push(dev.name)
        return lines.join("\n");
    }


}
