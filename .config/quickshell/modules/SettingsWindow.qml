/*
    adapted from https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/settings.qml
        - titlebar w version badge, breadcrumbs, close button
        - nav rail and active pill
        - appears from corner flickout (bottom right corner)
*/

import qs
import "../components/commons"
import "../components/core"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "settings/"

/*!
    \qmltype SettingsWindow
    \inqmlmodule modules
    \inherits FloatingWindow
    \brief HEAVY WIP
*/

FloatingWindow {
    id: root

    // ---- navigation state ----
    property int currentPage: 0
    property bool railExpanded: true

    readonly property var pages: [{
        "id": "theming",
        "name": "Style & Palette",
        "glyph": "󰔎",
        "subtitle": "GTK, cursors, icons and colors"
    }, {
        "id": "bar",
        "name": "TopBar & Pills",
        "glyph": "󰃚",
        "subtitle": "Modules, clock, weather and monitors"
    }, {
        "id": "dashboard",
        "name": "Monitor & CRT",
        "glyph": "󰒋",
        "subtitle": "Hardware sensors, scanlines and glow"
    }, {
        "id": "sysinfo",
        "name": "System Info",
        "glyph": "󰋼",
        "subtitle": "Hardware, kernel, uptime and resources"
    }]

    property bool isOpen: false

    function toggle() {
        root.isOpen ? close() : open();
    }

    function open() {
        closeTimer.stop();
        root.isOpen = true;
    }

    function close() {
        root.isOpen = false;
        closeTimer.restart();
    }

    title: "gilDEan Settings"

    // ---- geometry ----
    implicitWidth: 1040
    implicitHeight: 680
    minimumSize: Qt.size(840, 540)
    color: "transparent"
    visible: root.isOpen || mainPanel.opacity > 0

    Timer {
        id: closeTimer
        interval: Settings.settingsPopupAnimDuration // has to match animation duration
    }

    IpcHandler {
        function toggle() {
            root.toggle();
        }

        function open() {
            root.open();
        }

        function close() {
            root.close();
        }

        target: "settings"
    }

    CrtPanel {
        id: mainPanel

        anchors.fill: parent
        glowColor: Theme.grvYellow
        opacity: root.isOpen ? 1 : 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                // --- titlebar ---

                Layout.fillWidth: true
                Layout.preferredHeight: 36
                spacing: 12

                // logo badge
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 6
                    color: Theme.grvYellow

                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        color: Theme.bg0
                        font.pixelSize: 16
                    }

                }

                // title + breadcrumb
                ColumnLayout {
                    spacing: -2
                    Layout.fillWidth: true

                    Text {
                        text: "GILDEAN // SETTINGS"
                        color: Theme.fg0
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: 13
                    }

                    Text {
                        text: root.pages[root.currentPage].name + " — " + root.pages[root.currentPage].subtitle
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // close buttn
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 4
                    color: closeMouse.containsMouse ? Theme.grvRed : Theme.bg2
                    border.color: closeMouse.containsMouse ? Theme.grvRedDim : Theme.bg3
                    border.width: 1

                    Text {
                        // TODO center this and make it pretty
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeMouse.containsMouse ? Theme.bg0 : Theme.fg0
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

            }

            // horizontal separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.bg3
            }

            // -- navigation rail + content pane
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.railExpanded ? 210 : 60
                    color: Theme.bg0_hard
                    radius: Theme.radius
                    border.color: Theme.bg2
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        // toggle expanded sidebar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 6
                            color: toggleRailMouse.containsMouse ? Theme.bg2 : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                spacing: 10

                                Text {
                                    text: root.railExpanded ? "󰅖" : "󰍜"
                                    color: Theme.fgMuted
                                    font.pixelSize: 14
                                }

                                Text {
                                    visible: root.railExpanded
                                    text: "Navigation"
                                    color: Theme.fgMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                            }

                            MouseArea {
                                id: toggleRailMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.railExpanded = !root.railExpanded
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.bg2
                            opacity: 0.6
                        }

                        // list open tabs
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                id: activeIndicator

                                width: parent.width
                                height: 40
                                y: root.currentPage * (40 + 6)
                                radius: 8
                                color: Theme.bg2
                                border.color: Theme.grvYellow
                                border.width: 1

                                Behavior on y {
                                    NumberAnimation {
                                        duration: 220
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.1
                                    }

                                }

                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 6

                                Repeater {
                                    model: root.pages

                                    delegate: Rectangle {
                                        required property var modelData
                                        required property int index

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        radius: 8
                                        color: "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            spacing: 12

                                            Text {
                                                text: modelData.glyph
                                                color: root.currentPage === index ? Theme.grvYellow : (navItemMouse.containsMouse ? Theme.fg0 : Theme.fg3)
                                                font.pixelSize: 16

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 120
                                                    }

                                                }

                                            }

                                            Text {
                                                visible: root.railExpanded
                                                text: modelData.name
                                                color: root.currentPage === index ? Theme.fg0 : (navItemMouse.containsMouse ? Theme.fg1 : Theme.fgMuted)
                                                font.family: Theme.fontFamily
                                                font.bold: root.currentPage === index
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 120
                                                    }

                                                }

                                            }

                                        }

                                        MouseArea {
                                            id: navItemMouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.currentPage = index
                                        }

                                    }

                                }
                                // spacer

                                Item {
                                    Layout.fillHeight: true
                                }

                            }

                        }

                        //footer inspired by end4 FAB
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 6
                            color: fabMouse.containsMouse ? Theme.hover : Theme.bg1
                            border.color: Theme.bg3
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰅍"
                                    color: Theme.grvAqua
                                    font.pixelSize: 13
                                }

                                Text {
                                    visible: root.railExpanded
                                    text: "theming.conf"
                                    color: Theme.fg1
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                }

                            }

                            MouseArea {
                                id: fabMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + Settings.themeConfPath])
                            }

                        }

                    }

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                // content panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.bg0
                    radius: Theme.radius
                    border.color: Theme.bg2
                    border.width: 1
                    clip: true

                    // pages stack
                    Item {
                        // TODO implement lazy loading
                        anchors.fill: parent
                        anchors.margins: 18

                        // 1. theming page (index=0)
                        ThemingPageView {
                            anchors.fill: parent
                            visible: root.currentPage === 0
                            opacity: visible ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }

                            }

                        }

                        // 2. system info page (index=3)
                        SystemInfoView {
                            anchors.fill: parent
                            visible: root.currentPage === 3
                            opacity: visible ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }

                            }

                        }

                        // 3. placeholder (index=n)
                        Item {
                            anchors.fill: parent
                            visible: root.currentPage !== 0 && root.currentPage !== 3

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: root.pages[root.currentPage].glyph
                                    color: Theme.grvYellow
                                    font.pixelSize: 44
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "'" + root.pages[root.currentPage].name + "' section coming soon"
                                    color: Theme.fg2
                                    font.family: Theme.fontFamily
                                    font.bold: true
                                    font.pixelSize: 14
                                }

                            }

                        }

                    }

                }

            }

        }

        // slide animation (from right side)
        transform: Translate {
            x: root.isOpen ? 0 : 120

            Behavior on x {
                NumberAnimation {
                    duration: Settings.settingsPopupAnimDuration
                    easing.type: Easing.OutCubic
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Settings.settingsPopupOpacityAnimDuration
                easing.type: Easing.OutCubic
            }

        }

    }

}
