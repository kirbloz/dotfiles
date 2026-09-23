// services/BatteryService.qml
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property string batteryPath: "/sys/class/power_supply/BAT1"
     property int capacity: 100
     property string status: "Unknown"

    readonly property bool isCharging: status === "Charging" || status === "Full"
    readonly property bool isCritical: capacity <= 20 && !isCharging

    readonly property string icon: {
        //if (isCharging) return ""
        const icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰂄"]
        let index = Math.min(10, Math.max(0, Math.floor(capacity / 10)))
        return icons[index]
    }

    FileView {
        id: capacityFile
        path: root.batteryPath + "/capacity"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const val = parseInt(text().trim())
            if (!isNaN(val))
                root.capacity = val
        }
    }

    FileView {
        id: statusFile
        path: root.batteryPath + "/status"
        watchChanges: true
        onFileChanged: reload()
         onLoaded: {
            root.status = text().trim()
        }
    }
}