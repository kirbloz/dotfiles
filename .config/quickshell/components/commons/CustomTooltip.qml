import QtQuick
import Quickshell
import "../.."

PopupWindow {
    id: root

    required property Item anchorItem  // l'elemento a cui il tooltip è "agganciato"
    property string text: ""
    property bool show: false

    visible: show && text.length > 0
    color: "transparent"
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 12

    // ancorato all'item stesso: le coordinate sono relative all'angolo
    // in alto a sinistra dell'item, non alla finestra
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