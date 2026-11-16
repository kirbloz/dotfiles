import qs
import "../commons"
import QtQuick.Layouts

/*!
    \qmltype QuickTogglesGrid
    \inqmlmodule components.controlcenter
    \inherits GridLayout
    \brief widget with a grid-like buttons layout
    */

GridLayout {
    id:root
    columns: 2
    columnSpacing: 10
    rowSpacing: 10
    Layout.fillWidth: true

    // deafen
    QuickButton {
        Layout.fillWidth: true
        text: "  Volume"
        command: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        updateCommand: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo false || echo true"
    }

    // mute
    QuickButton {
        Layout.fillWidth: true
        text: " Microphone"
        command: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        updateCommand: "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo false || echo true"
    }

    // wifi
    QuickButton {
        Layout.fillWidth: true
        text: "󰖩 Wifi"
        command: "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"
        updateCommand: "nmcli radio wifi | grep -q enabled && echo true || echo false"
    }

    // bluetooth
    QuickButton {
        Layout.fillWidth: true
        text: "󰂯 Bluetooth"
        command: "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"
        updateCommand: "bluetoothctl show | grep -q 'Powered: yes' && echo true || echo false"
    }

    // airplane mode
    QuickButton {
        Layout.fillWidth: true
        text: "󰀝 Airplane Mode"
        command: "nmcli networking | grep -q enabled && nmcli networking off || nmcli networking on"
        updateCommand: "nmcli networking | grep -q disabled && echo true || echo false"
        Layout.columnSpan: 2
    }
}
