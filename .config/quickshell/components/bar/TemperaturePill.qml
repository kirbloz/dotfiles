import qs
import qs.services
import "../core"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

WidgetBase {

    id: tempPill

    property int tempValue: 0
    property int criticalThreshold: Settings.criticalTempThreshold
    property int warningThreshold: Settings.warningTempThreshold

    severity: tempValue >= criticalThreshold ? "critical" : (tempValue >= warningThreshold ? "warning" : "normal")
    tooltipText: "CPU Temp: " + tempValue + "°C Right click for btop"
    onClicked: PopupService.toggle("dashboard", tempPill)
    onRightClicked: {
        try {
            Quickshell.execDetached(["kitty", "-e", "btop"]);
        } catch (e) {
            console.warn("[TempPill] cannot start btop: ", e);
        }
    }

    // hwmon every 5s
    Timer {
        interval: 5000
        // TODO remove this
        running: false
        repeat: true
        triggeredOnStart: true
    }

    FileView {
        path: "/sys/class/hwmon/hwmon5/temp1_input"
        watchChanges: true
        onLoaded: tempPill.tempValue = Math.round(parseInt(text().trim()) / 1000)
    }

    Text {
        text: ""
        color: tempPill.severity === "critical" ? Theme.grvRed : (tempPill.severity === "warning" ? Theme.grvYellow : "#fab387")
        font.pixelSize: 14
    }

    Text {
        text: tempPill.tempValue + "°C"
        color: tempPill.severity === "critical" ? Theme.grvRed : Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true
    }

}
