import QtQuick.Layouts
import "../.."
import ".."

MenuButton {

    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true
    label: "\uf011 Power Menu"
    actions: [{
        "label": "  Lock",
        "command": "hyprlock"
    }, {
        "label": "  Logout",
        "command": "hyprctl dispatch exit"
    }, {
        "label": "  Reboot",
        "command": "systemctl reboot"
    }, {
        "label": "  Shutdown",
        "command": "systemctl poweroff"
    }]
}
