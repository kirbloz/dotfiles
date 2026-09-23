// started from https://github.com/tripathiji1312/quickshell/blob/main/modules/osd/Wrapper.qml
// https://github.com/tripathiji1312/quickshell/blob/main/modules/osd/VolumeOSD.qml

import "../.." // Theme
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    //default property alias content: contentContainer.data

    id: root

    property string icon: ""
    property string valueText: ""
    property real percentage: 0
    property bool muted: false
    property color accentColor: Theme.grvYellow
    property bool showing: false
    property int hideInterval: 1800

    readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(root.screen)
    readonly property bool isFocusedMonitor: Hyprland.focusedMonitor?.id === hyprMonitor?.id

    

    function show() {
        showing = true;
        hideTimer.restart();
    }

    visible: showing && isFocusedMonitor
    //implicitWidth: bubble.implicitWidth
    implicitHeight: bubble.implicitHeight
    color: "transparent"
     exclusionMode: ExclusionMode.Ignore
    

    anchors {
        top: true
        right: true
        left:true
    }

    margins {
        top: 55
        //right: 16
    }

    Timer {
        id: hideTimer
        interval: root.hideInterval
        onTriggered: root.showing = false
    }

    Rectangle {
        id: bubble
        property int pad: 5

        opacity: root.showing ? 0.85 : 0
        scale: root.showing ? 1 : 0.95
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
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
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: root.muted ? Theme.fgMuted : root.accentColor
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                id: barTrack

                Layout.preferredWidth: 100
                Layout.maximumWidth: 100
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
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }
                }

                /*Rectangle {
                    width: 12
                    height: width
                    radius: width / 2
                    x: Math.max(0, Math.min(parent.width - width, parent.width * (root.percentage / 100) - width / 2))
                    y: (parent.height - height) / 2
                    color: root.muted ? Theme.fgMuted : root.accentColor
                    border.width: 1
                    border.color: Theme.bg3
                }*/
            }

            Text {
                text: root.valueText
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: Theme.fg0
                Layout.preferredWidth: 42
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

    mask: Region {
        item: bubble
    }

}
