import "../../services" as Services
import "../.."
import "../core"
import QtQuick

WidgetBase {
    id: clockPill
    type: "clock"

    property bool showSeconds: false
    readonly property real timeMs: Services.TimeService.currentTimestamp

    onClicked: console.log("ClockPill clicked at:", timeLabel.text)

    Text {
        id: timeLabel
        text: Services.TimeService.formatTime(new Date(clockPill.timeMs), clockPill.showSeconds)
        color: Theme.fg0
        font.pixelSize: 14
        font.bold: true
    }
}