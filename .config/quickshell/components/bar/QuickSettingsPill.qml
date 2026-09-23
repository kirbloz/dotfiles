import "../.."
import "../../services"
import "../commons"
import "../core"
import QtQuick
import QtQuick.Layouts

WidgetBase {
    id: qsPill

    property var screen: null

    signal openControlCenterRequested()

    type: "quicksettings"
    interactive: false // ogni indicatore gestisce i propri click
    spacing: 12

    IndicatorIcon {
        glyph: NetworkService.netType === "WIFI" ? "" : NetworkService.netType === "ETH" ? "" : ""
        glyphColor: NetworkService.netType === "DISCONNECTED" ? Theme.grvRed : "white"
        tooltipText: NetworkService.tooltipText
        launchCommand: ["nm-connection-editor"]
    }

    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    IndicatorIcon {
        glyph: BluetoothService.status === "OFF" ? "  " : ""
        glyphColor: BluetoothService.status === "CONNECTED" ? Theme.grvAqua : BluetoothService.status === "ON" ? Theme.grvBlue : "#666666"
        tooltipText: BluetoothService.tooltipText
        launchCommand: ["blueman-manager"]
    }

    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    RowLayout {
        spacing: 4

        IndicatorIcon {
            glyph: AudioService.muted ? "" : (AudioService.percentage > 50 ? "" : "")
            glyphColor: AudioService.muted ? "#666666" : Theme.fg0
            launchCommand: ["pavucontrol"]
            onRightClicked: AudioService.toggleMute()
        }

        Text {
            text: AudioService.percentage + "%"
            font.pixelSize: 13
            font.bold: true
            color: AudioService.muted ? "#666666" : Theme.fg0
        }

    }

    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    IndicatorIcon {
        glyph: ""
        glyphColor: "#666666"
        onClicked: ControlCenterService.toggleFrom(qsPill, qsPill.screen)
    }


}
