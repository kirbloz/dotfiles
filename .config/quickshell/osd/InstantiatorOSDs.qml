
import Quickshell
import QtQuick

/*!
    \qmltype InstantiatorOSD
    \inherits Item
    \inqmlmodule osd
    \brief container element for OSDs; knows what screen it needs to instantiate osds for
*/

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