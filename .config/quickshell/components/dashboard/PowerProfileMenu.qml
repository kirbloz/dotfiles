import qs
import ".."
import QtQuick.Layouts

/*!
    \qmltype PowerProfileMenu
    \inherits MenuButton
    \inqmlmodule components.dashboard
    \brief dropdown menu to switch power profiles using power-profiles-daemon or TLP

    \note i dont think this is working DEBUG
*/

MenuButton {
    Layout.alignment: Qt.AlignTop
    Layout.fillWidth: true
    label: "󰚥 Power Profile"
    actions: [{
        "label": "󱐋  Performance",
        "command": "powerprofilesctl set performance || tlp ac"
    }, {
        "label": "  Balanced",
        "command": "powerprofilesctl set balanced || tlp bat"
    }, {
        "label": "  Power Saver",
        "command": "powerprofilesctl set power-saver || tlp bat"
    }]
}
