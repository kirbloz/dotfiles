// inspired from https://github.com/tripathiji1312/quickshell/blob/main/modules/osd/Wrapper.qml
// https://github.com/tripathiji1312/quickshell/blob/main/modules/osd/VolumeOSD.qml

import qs
import "../commons"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

/*!
    \qmltype BubbleOSD
    \inherits PanelWindow
    \inqmlmodule osd
    \brief lightweight on-screen display (OSD) pill for volume and brightness feedback

    BubbleOSD renders a transient feedback pill anchored near the top of the monitor; automatically routes display visibility to the currently focused Hyprland output and unmaps itself from Wayland once the fade-out animation completes

    example usage:
    \code
    BubbleOSD {
        icon: AudioService.muted ? "" : ""
        valueText: AudioService.percentage + "%"
        percentage: AudioService.percentage
        muted: AudioService.muted
        accentColor: Theme.grvYellow
    }
    \endcode
*/

PanelWindow {

    id: root

    // ---- public properties ----
    property string icon: ""
    property string valueText: ""
    property real percentage: 0
    property bool muted: false
    property color accentColor: Theme.grvYellow
    property bool showing: false
    property int hideInterval: 1800

    // ---- monitor focus binding ----
    readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(root.screen)
    readonly property bool isFocusedMonitor: Hyprland.focusedMonitor?.id === hyprMonitor?.id

    /*! \qmlmethod void BubbleOSD::show()
        presents the OSD on the focused screen and resets the dismissal timer */
    function show() {
        isWindowVisible = true
        showing = true;
        hideTimer.restart();
    }

    // ---- window ----
    property bool isWindowVisible: false
    visible: isWindowVisible && isFocusedMonitor
    implicitHeight: bubble.implicitHeight
    implicitWidth: bubble.implicitWidth
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
    }

    margins {
        top: 55
    }

    mask: Region {
        item: bubble
    }

    // ---- timers ----
    Timer {
        id: hideTimer
        interval: root.hideInterval
        onTriggered: {
            root.showing = false
            closeTimer.start()}
    }
    Timer {
        id: closeTimer
        interval: 200 // exit animation duration
        onTriggered: root.isWindowVisible = false
    }

    // ---- view ----
    Rectangle {
        id: bubble
        property int pad: 5

        opacity: root.showing ? 0.85 : 0
        scale: root.showing ? 1 : 0.92

        // ---- geometry ----
        color: Theme.darkgray
        radius: height / 2
        implicitWidth: layout.implicitWidth + bubble.pad * 2 * 2
        implicitHeight: layout.implicitHeight + bubble.pad * 2

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 14

            Text {
                text: root.icon
                font.family: Glyphs.fontFamily
                font.pixelSize: 14
                color: root.muted ? Theme.fgMuted : root.accentColor
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                id: barTrack

                Layout.preferredWidth: 100
                Layout.preferredHeight: 8
                radius: height / 2
                color: Theme.bg2
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: barFill
                    width: barTrack.width * Math.max(0, Math.min(100, root.percentage)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: root.muted ? Theme.fgMuted : root.accentColor

                    Behavior on width {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }

            Text {
                text: root.valueText
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.fg0
                Layout.preferredWidth: 26
                horizontalAlignment: Text.AlignRight
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutBack
            }

        }

    }


}
