//import QtQuick.Layouts
//import Quickshell
//import Quickshell.Io

import "../.."
import "../../services"
import "../core"
import QtQuick

WidgetBase {
    id: batPill

    property bool showAlt: false

    type: "battery"
    bgBase: BatteryService.isCritical ? Theme.grvRed : Theme.darkgray
    onClicked: batPill.showAlt = !batPill.showAlt

    Text {
        text: BatteryService.icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
        color: BatteryService.isCritical ? Theme.grvRed : Theme.fg0
    }

    Text {
        text: batPill.showAlt ? BatteryService.status : (BatteryService.capacity + "%")
        font.pixelSize: 14
        font.bold: true
        color: BatteryService.isCritical ? Theme.grvRed : Theme.fg0
    }

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
