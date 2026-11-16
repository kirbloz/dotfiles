import QtQuick
import QtQuick.Layouts
import qs

/*!
    \qmltype InfoRow
    \inqmlmodule components.commons
    \inherits RowLayout
    \brief customized RowLayout; displays \c {key} and \c {value} on the same row with a spacing
*/

RowLayout {
        property string key: ""
        property string value: ""

        Layout.fillWidth: true
        /*! spacing between key and value
            defaults to \c {12}
            */
        spacing: 12

        Text {
            text: parent.key
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            Layout.preferredWidth: 110
        }

        Text {
            text: parent.value
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }