import QtQuick
import Quickshell
import qs

/*!
    \qmltype CustomTooltip
    \inqmlmodule components.commons
    \inherits PopupWindow
    \brief tooltip with customizable text; appears under anchor item 
*/
PopupWindow {
    id: root

    required property Item anchorItem
    property string text: ""
    property bool show: false

    visible: show && text.length > 0
    color: "transparent"
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 12

    // anchors itself onto referenced item
    // -> top-left of the item, not the tooltip itself
    anchor.item: anchorItem
    anchor.rect.x: (anchorItem.width - implicitWidth) / 2
    anchor.rect.y: anchorItem.height + 6

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.darkgray
        border.color: "#444444"
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }
    }
}