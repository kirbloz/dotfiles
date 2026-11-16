import QtQuick.Layouts
import qs
import ".."

/*!
    \qmltype PowerMenu
    \inherits MenuButton
    \inqmlmodule components.dashboard
    \brief dropdown menu for session management (lock, logout, reboot, shutdown)
*/

MenuButton {

    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true
    label: "  Power Menu"
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
