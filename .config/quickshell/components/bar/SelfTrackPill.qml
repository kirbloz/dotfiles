import "../.."
import "../core"
import QtQuick

WidgetBase {
    id: root
    type: "selftrack"

    enableHover: true
    bgHover: Theme.bg2

    Text {
        text: "󰔛"
        color: Theme.fg0
        font.pixelSize: 15
    }
}