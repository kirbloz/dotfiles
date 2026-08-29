import "../.."
import QtQuick
import QtQuick.Layouts

// Barra sola-lettura, stesso linguaggio visivo degli slider ma senza
// interazione — per mostrare percentuali di utilizzo (CPU/RAM/disco).
RowLayout {
    id: barRoot

    property string label: ""
    property real value: 0 // 0..1
    property string valueText: Math.round(value * 100) + "%"
    property color barColor: Theme.grvYellow

    Layout.fillWidth: true
    spacing: 10

    Text {
        text: barRoot.label
        color: Theme.fg1
        font.family: Theme.fontFamily
        font.pixelSize: 11
        Layout.preferredWidth: 60
        Layout.minimumWidth: 60
        elide: Text.ElideRight
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 8
        radius: 4
        color: Theme.bg3

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, barRoot.value))
            height: parent.height
            radius: 4
            color: barRoot.barColor

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

    Text {
        text: barRoot.valueText
        color: Theme.fgMuted
        font.family: Theme.fontFamily
        font.pixelSize: 11
        Layout.preferredWidth: 78 // era 68, "10.4 / 15.0 GB" è largo
        Layout.minimumWidth: 78
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
    }

}
