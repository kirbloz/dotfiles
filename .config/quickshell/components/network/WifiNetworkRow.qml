import qs
import "../commons"
import QtQuick
import QtQuick.Layouts

/*!
    \qmltype WifiNetworkRow
    \inherits Rectangle
    \inqmlmodule components.network
    \brief list delegate item representing an available wifi access point with signal and lock indicators
*/

Rectangle {
    id: root

    property string ssid: ""
    property int strength: 0
    property bool secured: false
    property bool inUse: false

    signal activated()

    implicitHeight: 36
    radius: Theme.radius - 2
    color: root.inUse ? Theme.bg3 : (area.containsMouse ? Theme.bg4 : Theme.bg2)
    border.color: root.inUse ? Theme.grvYellow : "transparent"
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: Glyphs.wifi(root.strength)
            color: root.inUse ? Theme.grvYellow : Theme.fg1
            font.family: Glyphs.fontFamily
            font.pixelSize: 14
        }

        Text {
            text: root.ssid
            color: root.inUse ? Theme.grvYellow : Theme.fg0
            font.family: Theme.fontFamily
            font.weight: root.inUse ? Font.DemiBold : Font.Normal
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.secured
            text: Glyphs.lock
            color: Theme.fgMuted
            font.family: Glyphs.fontFamily
            font.pixelSize: 12
        }

        
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
