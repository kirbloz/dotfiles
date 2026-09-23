import ".."
import "../components/bar"
import QtQuick
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// base bar
PanelWindow {
    id: rootBar

    signal openNotifCenterRequested()
    signal openControlCenterRequested()
    signal openSelfTrackRequested()

    screen: modelData
    implicitHeight: 40 
    // Sfondo della barra
    // color: // 0.2 * 255 ≈ 51 = 0x33
    color: "#33000000"

    anchors {
        top: true 
        left: true
        right: true
    }

    Item {
        anchors.fill: parent
        anchors.margins: 5 

        // LEFT MODULES
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10


            //CustomExit {}
            ClockPill {
            }
            //  meteo, finestre hyprland e mpris
            WeatherPill {
            }

        SelfTrackPill{
            onClicked: rootBar.openSelfTrackRequested()
        }
        }

        // CENTER MODULE
        RowLayout {
            anchors.centerIn: parent
            HyprlandWorkspaces {
            }

        }

        // RIGHT MODULES
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            //NetworkPill {}
            //BluetoothPill {}
            //AudioPill {}
            QuickSettingsPill {
                screen: rootBar.screen
                onOpenControlCenterRequested: rootBar.openControlCenterRequested()
            }
            TemperaturePill {
            }
            BatteryPill {
            }
            TrayPill {
            }
            CustomNotifications {
               onOpenNotifCenterRequested: rootBar.openNotifCenterRequested()
            }

        }

    }

}
