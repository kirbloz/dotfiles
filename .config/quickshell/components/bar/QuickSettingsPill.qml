import qs
import qs.services
import "../commons"
import "../core"
import QtQuick
import QtQuick.Layouts

/*! 
    \qmltype QuickSettingsPill
    \inherits WidgetBase
    \inqmlmodule components.bar
    \brief composite status bar capsule aggregating core system, network, and audio controls

    QuickSettingsPill unifies multiple hardware and connectivity indicators inside a single pill

    \note because each indicator features independent click, scroll, and tooltip behaviors, the parent \l WidgetBase has its global \c interactive property disabled

    integrated indicators:
    \list
        \li \b {Network}: Wi-Fi signal or Ethernet status; clicking opens the Network popup
        \li \b {Bluetooth}: BT connection state; clicking launches \c blueman-manager
        \li \b {Audio}: mute and volume levels; click (launches \c pavucontrol), right-click (toggles mute), and wheel scrolling (adjusts volume by ±5%)
        \li \b {Control Center}: action icon to toggle the shell's control center popup panel
    \endlist

    Example usage:
    \code
    import "../components/bar"

    TopBar {
        // embedded directly inside the right layout row
        QuickSettingsPill {}
    }
    \endcode
    */

WidgetBase {
    id: root

    type: "quicksettings"
    /*! \internal disables the parent capsule's MouseArea so individual child icons can capture and handle pointer events */
    interactive: false
    spacing: 12

    // connectivity
    GlyphIcon {
        glyph: NetworkService.netType === "WIFI" ? Glyphs.wifi(NetworkService.sigStrength) : (NetworkService.netType === "ETH" ? "" : "")
        color: NetworkService.netType === "DISCONNECTED" ? Theme.grvRed : "white"
        tooltipText: NetworkService.tooltipText
        onClicked: {
            PopupService.toggle("network", this);
        }
    }

    // separator
    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    // bluetooth indicator 
    GlyphIcon{
        glyph: BluetoothService.status === "OFF" ? "  " : ""
        color: BluetoothService.status === "CONNECTED" ? Theme.grvAqua : BluetoothService.status === "ON" ? Theme.grvBlue : "#666666"
        tooltipText: BluetoothService.tooltipText
        command: ["blueman-manager"]
    }

    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    // audio indicator
    GlyphIcon {
        glyph: AudioService.muted ? "" : (AudioService.percentage > 50 ? (AudioService.percentage > 75 ? "" : "") : "")
        color: AudioService.muted ? "#666666" : Theme.fg0
        // TODO enable custom spacing
        //spacing: 4
        command: ["pavucontrol"]
        // TODO instead of "volume" i could display the name of the primary output device
        tooltipText: "Volume: " + AudioService.percentage + "%"
        readonly property int volumeAdjustStep: Settings.volumeAdjustStep
        onRightClicked: AudioService.toggleMute()
        onWheelScrolled: (delta) => {
            return AudioService.adjustVolume(delta > 0 ? volumeAdjustStep : - volumeAdjustStep);
        }
    }

    Rectangle {
        width: 2
        height: 14
        color: "#444444"
    }

    // control center trigger
    GlyphIcon{
        glyph: ""
        color: "#666666"
        hoverColor: Theme.fg3
        onClicked: PopupService.toggle("controlCenter", this)
    }

}
