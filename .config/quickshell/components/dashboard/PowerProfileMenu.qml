import "../.."
import ".."
import QtQuick.Layouts

MenuButton {
    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true
    label: "󰚥 Power Profile"
    actions: [{
        "label": "󱐋  Performance",
        "command": "sudo tlp ac"
    }, {
        "label": "  Balanced",
        "command": "sudo tlp bat"
    }, {
        "label": "  TLP Start",
        "command": "sudo tlp start"
    }]
}
