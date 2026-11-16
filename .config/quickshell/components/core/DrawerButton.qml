import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import qs
import "../commons"

/*!
    \qmltype DrawerButton
    \inherits Rectangle
    \brief interactive pill button with icon and optional text label designed for the corner flyout
*/

Rectangle {
    id: btn

    property string icon: ""
    property string label: ""
    property color accent: Theme.grvYellow

    signal clicked()

    implicitHeight: 38
    implicitWidth: label !== "" ? btnRow.implicitWidth + 28 : 38
    radius: 14
    color: btnMouse.pressed ? Theme.bg3 : (btnMouse.containsMouse ? Theme.bg2 : Theme.bg1)

    Behavior on color {
        ColorAnimation {duration:120}
    }

    RowLayout {
        id: btnRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: btn.icon
            color: btn.accent
            font.family: Glyphs.fontFamily
            font.pixelSize: 16
        }

        Text {
            visible: btn.label !== ""
            text: btn.label
            color: Theme.fg0
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12
        }

    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
