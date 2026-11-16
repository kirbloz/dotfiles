/*!
    \qmltype BatteryService
    \inherits Singleton
    \inqmlmodule services
    \brief power supply reader for battery capacity, charging status, and critical alerts
*/

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io


Singleton {
    id: root

    readonly property string batteryPath: (typeof Settings !== "undefined" && Settings.batteryHw) ? Settings.batteryHw : "/sys/class/power_supply/BAT1"
    property int capacity: 100
    property string status: "Unknown"
    readonly property int refreshMs: 180000
    readonly property bool isCharging: status === "Charging" || status === "Full"
    readonly property bool isCritical: capacity <= 20 && !isCharging
    readonly property string icon: {
        const icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰂄"];
        let index = Math.min(10, Math.max(0, Math.floor(capacity / 10)));
        return icons[index];
    }

    FileView {
        id: capacityFile

        path: root.batteryPath + "/capacity"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const val = parseInt(text().trim());
            if (!isNaN(val))
                root.capacity = val;

        }
    }

    FileView {
        id: statusFile

        path: root.batteryPath + "/status"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.status = text().trim();
        }
    }

    // stupid ass linux files dont guarantee events and load doesnt trigger
    // having a trigger is a good failsafe
    Timer {
        interval: refreshMs // every three minutes
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload();
            statusFile.reload();
        }
    }

}
