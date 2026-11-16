import qs
import qs.services
import "../core"
import QtQuick

WidgetBase {
    id: root

    type: "selftrack"
    enableHover: true
    severity: "normal" 
    
    onClicked: {
        console.log("[SelfTrackPill] Click detected, referenced popup:", root);
        PopupService.toggle("selfTrack", root)
    }

    Text {
        text: "󰔛"
        color: root.severity === "warning" ? Theme.grvYellow : Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 15
    }

}
