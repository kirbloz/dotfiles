import QtQuick
import "../.."
import QtQuick.Layouts


RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 20

    property real rx: 0
    property real tx: 0

    RowLayout {
        spacing: 6

        Text {
            text: "󰇚"
            color: Theme.grvAqua
            font.pixelSize: 14
        }

        Text {
            text: root.rx.toFixed(0) + " KB/s"
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

    }

    RowLayout {
        spacing: 6

        Text {
            text: "󰕒"
            color: Theme.grvYellow
            font.pixelSize: 14
        }

        Text {
            text: root.tx.toFixed(0) + " KB/s"
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

    }

    Item {
        Layout.fillWidth: true
    }

}
