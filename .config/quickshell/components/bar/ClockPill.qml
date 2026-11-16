import qs
import qs.services
import "../core"
import QtQuick

WidgetBase {
    id: root
    type: "clock"

    property bool showSeconds: false
    readonly property real timeMs: TimeService.currentTimestamp

    onClicked: root.showSeconds = !root.showSeconds
    severity: "normal"

    //onClicked: PopupService.toggle("dashboard", tempPill);
    onRightClicked: {
        try {
            PopupService.toggle("calendar", root);
        }catch(e){
            console.warn("[ClockPill] cannot start calendar widget: ", e);
        }
    }

    Text {
        id: timeLabel
        text: TimeService.formatTime(new Date(TimeService.currentTimestamp), root.showSeconds)
        color: Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
    }
}