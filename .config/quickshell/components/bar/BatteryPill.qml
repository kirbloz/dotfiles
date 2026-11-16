import qs
import qs.services
import "../core"
import QtQuick

WidgetBase {
    id: root
    type: "battery"

    //property bool showAlt: false
    property bool showPercentage: true

    severity: BatteryService.isCritical ? "critical" : (BatteryService.isCharging ? "active" : "normal")
    onClicked: root.showPercentage = !root.showPercentage

    border.width: severity !== "normal" ? 2 : 0


    Text {
        text: BatteryService.icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
        color: BatteryService.isCritical ? Theme.grvRed : Theme.fg0
    }

    Text {
        text: root.showPercentage ? (BatteryService.capacity + "%") : BatteryService.status
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
        color: BatteryService.isCritical ? Theme.grvRed : Theme.fg0
    }

    // what about this animation? is it working? TODO
    SequentialAnimation on opacity {
        running: BatteryService.isCritical
        loops: Animation.Infinite

        NumberAnimation {
            to: 0.4
            duration: Theme.animationDuration
            easing.type: Easing.Linear
        }

        NumberAnimation {
            to: 1
            duration: Theme.animationDuration
            easing.type: Easing.Linear
        }

    }

}
