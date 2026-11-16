import QtQuick
import qs
import "../commons"
import QtQuick.Layouts

/*!
    \qmltype NetworkStatsRow
    \inherits RowLayout
    \inqmlmodule components.dashboard
    \brief inline transfer rate monitor displaying Rx (download) and Tx (upload) speeds
*/

// TODO there is some code around that can be reused for this file 

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 20

    /*! \qmlproperty real NetworkStatsRow::rx
        current download rate in KB/s */
    property real rx: 0
    /*! \qmlproperty real NetworkStatsRow::tx
        current upload rate in KB/s */
    property real tx: 0

    function formatRate(kbs) {
        if (kbs >= 1024)
            return (kbs / 1024).toFixed(1) + " MB/s";
        return kbs.toFixed(0) + " KB/s";
    }

    RowLayout {
        spacing: 6

        Text {
            text: "󰇚"
            color: Theme.grvAqua
            font.family: Glyphs.fontFamily
            font.pixelSize: 14
        }

        Text {
            text: root.formatRate(root.rx)
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
            font.family: Glyphs.fontFamily
            font.pixelSize: 14
        }

        Text {
            text: root.formatRate(root.tx)
            color: Theme.fg1
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

    }

    Item {
        Layout.fillWidth: true
    }

}
