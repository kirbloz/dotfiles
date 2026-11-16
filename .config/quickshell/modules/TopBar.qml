import qs
import qs.services
import "../components/bar"
import "../components/commons"
import QtQuick
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// base bar
PanelWindow {
    id: rootBar

    screen: modelData
    implicitHeight: 40
    // background
    color: "#33000000"

    anchors {
        top: true
        left: true
        right: true
    }

    Item {
        id: barContent
        anchors.fill: parent
        anchors.margins: 5

        property var screen: rootBar.screen

        // LEFT MODULES
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            //CustomExit {}
            ClockPill {
            }

            // meteo, win hyprland, mpris
            WeatherPill {
            }

            SelfTrackPill {
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

            QuickSettingsPill {
            }

            TemperaturePill {
            }

            BatteryPill {
            }

            TrayPill {
            }

            NotificationPill {
            }

        }

    }

}
