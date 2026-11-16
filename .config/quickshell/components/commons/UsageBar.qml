import qs
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    //TODO i feel like "StatBar" and this object could be fused togheter
    property string title: ""
    property string detail: ""
    property real fraction: 0
    property color accent: Theme.grvYellow

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: parent.parent.title
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Text {
            text: (parent.parent.detail !== "" ? parent.parent.detail + "  \u00b7  " : "") + Math.round(parent.parent.fraction * 100) + "%"
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 8
        radius: 4
        color: Theme.bg3

        Rectangle {
            height: parent.height
            width: parent.width * parent.parent.fraction
            radius: 4
            color: parent.parent.fraction > 0.9 ? Theme.grvRed : parent.parent.accent

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
