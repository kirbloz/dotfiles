import QtQuick
import QtQuick.Layouts
import "../.."

RowLayout {
    id: root
    Layout.fillWidth: true

    property string title: ""
    signal closeRequested()

    Text {
        text: root.title
        color: Theme.grvYellow
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: 15
    }

    Item {
        Layout.fillWidth: true
    }

    Text {
        text: "󰅖"
        color: Theme.fgMuted
        font.pixelSize: 16

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }

    }

}
