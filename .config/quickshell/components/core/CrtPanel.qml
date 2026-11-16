import qs
import "../effects"
import QtQuick
import QtQuick.Effects

/*! 
    \qmltype CrtPanel
    \inqmlmodule components.core
    \inherits Rectangle
    \brief retro-CRT styled block; has colored border and glow + "scanlines" effect

    used by popups, children end up as content
    this thing is heavy. but i crave the retro look GIMME GIMME
*/

Rectangle {
    id: root

    property color glowColor: Theme.grvYellow
    default property alias content: contentHost.data

    radius: Theme.radius + 4
    color: Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.9)
    border.color: root.glowColor
    border.width: 1

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.glowColor
        border.width: 1
        radius: root.radius
        layer.enabled: true

        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            blur: 0.8
            autoPaddingEnabled: true
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        CrtScanlines {
            anchors.fill: parent
            anchors.margins: 2
        }

        Item {
            id: contentHost

            anchors.fill: parent
        }
    }
}
