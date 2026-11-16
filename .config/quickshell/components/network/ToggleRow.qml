import qs
import "../commons"
import QtQuick
import QtQuick.Layouts

/*!
    \qmltype ToggleRow
    \inherits Rectangle
    \inqmlmodule components.network
    \brief generic interactive row containing a leading glyph, label, and toggle switch
*/
Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property bool checked: false

    signal toggled(bool value)

    implicitHeight: 38
    radius: Theme.radius
    color: area.containsMouse ? Theme.hover : Theme.bg2
    border.color: root.checked ? Theme.grvYellow : Theme.bg3
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            text: root.glyph
            color: root.checked ? Theme.grvYellow : Theme.fgMuted
            font.family: Glyphs.fontFamily
            font.pixelSize: 16
        }

        Text {
            text: root.label
            color: Theme.fg0
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 18
            radius: 9
            color: root.checked ? Theme.grvYellow : Theme.bg3

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: Theme.bg1
                anchors.verticalCenter: parent.verticalCenter
                x: root.checked ? parent.width - width - 3 : 3

                Behavior on x {
                    NumberAnimation { duration: 150 }
                }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
