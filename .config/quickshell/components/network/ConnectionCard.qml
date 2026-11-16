import qs
import "../commons"
import QtQuick
import QtQuick.Layouts

/*! 
    \qmltype ConnectionCard
    \inqmlmodule components.network
    \inherits Rectangle
    \brief view only; displays information about active network connection
*/

Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""

    implicitHeight: 46
    radius: Theme.radius
    color: Theme.bg2
    border.color: Theme.bg3
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        Text {
            text: root.glyph
            color: Theme.grvYellow
            font.family: Glyphs.fontFamily
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.subtitle
                color: Theme.fg1
                font.family: Theme.fontFamily
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
