import "."
import Quickshell
import QtQuick

Item {
    id: root
    required property var screen

    VolumeOSD {
        screen: root.screen
    }

    BrightnessOSD {
        screen: root.screen
    }

    // wip MicOSD { screen: root.screen }
}