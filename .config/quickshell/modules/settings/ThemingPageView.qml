import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."
import qs
import "../../components/commons"
import "../../components/core"
import "../../components"

/*!
    \qmltype ThemingPageView
    \inherits Flickable
    \inqmlmodule modules.settings
    \brief WORK IN PROGRESS; theming management page for configuring GTK, cursor, font sizes, and color schemes
*/

Flickable {
    id: root
    contentHeight: contentCol.implicitHeight + 20
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    property string confPath: Quickshell.env("HOME") + Settings.themeConfPath
    property string setupPath: Quickshell.env("HOME") + Settings.themeScriptPath

    property bool darkTheme: true
    property int cursorSize: 16
    property int fontSize: 10
    property string fontName: Theme.fontFamily
    property string statusLog: "Ready"

    // reads current values from theming.conf
    function parseConf(txt) {
        const conf = {};
        for (const line of txt.split("\n")) {
            const m = line.match(/^\s*([A-Z_]+)\s*=\s*"?([^"#]*)"?/);
            if (m)
                conf[m[1]] = m[2].trim();
        }
        if (conf.PREFER_DARK !== undefined)
            root.darkTheme = conf.PREFER_DARK !== "0";
        if (conf.CURSOR_SIZE)
            root.cursorSize = parseInt(conf.CURSOR_SIZE);
        if (conf.FONT_SIZE)
            root.fontSize = parseInt(conf.FONT_SIZE);
        if (conf.FONT_NAME)
            root.fontName = conf.FONT_NAME;
    }


    FileView { 
        path: root.confPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parseConf(text())
    }

    Process {
        id: applyProc
        stdout: StdioCollector {}
        stderr: StdioCollector { id: errOut }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.statusLog = "✓ GTK/Qt configs generated with success!";
            } else {
                const lines = errOut.text.trim().split("\n");
                root.statusLog = "✕ " + (lines[lines.length - 1] || "Error during scriptexecution");
            }
        }
    }

    function saveAndApply() {
        if (applyProc.running)
            return;
        root.statusLog = "applying customization now...";
        applyProc.command = [
            "bash", root.setupPath, root.confPath,
            "CURSOR_SIZE=" + root.cursorSize,
            "FONT_SIZE=" + root.fontSize,
            "PREFER_DARK=" + (root.darkTheme ? 1 : 0)
        ];
        applyProc.running = true;
    }

    ColumnLayout {
        id: contentCol
        width: parent.width - 12
        spacing: 16

        // Titolo Sezione
        RowLayout {
            spacing: 8
            Text { text: "󰔎"; color: Theme.grvYellow; font.family: Glyphs.fontFamily; font.pixelSize: 18 }
            Text { text: "Appearance & Theming"; color: Theme.fg0; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 15 }
        }

        // CARD 1: controls
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: card1Layout.implicitHeight + 24
            color: Theme.bg1
            radius: 8
            border.color: Theme.bg2
            border.width: 1

            ColumnLayout {
                id: card1Layout
                anchors.fill: parent
                anchors.margins: 14
                spacing: 24 // FIXME this doesnt change anything??

                // ---- dark theme ----
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: "prefer dark theme"; color: Theme.fg1; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
                        Text { text: "set portal xdg-desktop and GTK vars to dark"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }

                    Item{ Layout.fillWidth:true}

                    // custom switch (caelestia like)
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: root.darkTheme ? Theme.grvYellow : Theme.bg3
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            y: 3
                            x: root.darkTheme ? 23 : 3
                            color: root.darkTheme ? Theme.bg0 : Theme.fg2
                            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.darkTheme = !root.darkTheme
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.bg2 }

                // cursor size
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: "cursor size: " + root.cursorSize + "px"; color: Theme.fg1; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
                        Text { text: "synched across GTK, Qt and Hyprland"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }

                    CustomSlider {
                        id: cursorSlider
                        Layout.preferredWidth: 200
                        from: 16
                        to: 48
                        stepSize: 4
                        value: root.cursorSize
                        onMoved: (v) => root.cursorSize = Math.round(v)
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.bg2 }

                // font size
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { text: "interface font size: " + root.fontSize + "pt"; color: Theme.fg1; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
                        Text { text: "font family: " + Settings.themeFontName; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }

                    CustomSlider {
                        Layout.preferredWidth: 200
                        from: 8
                        to: 18
                        stepSize: 1
                        value: root.fontSize
                        onMoved: (v) => root.fontSize = v
                    }
                }
            }
        }

        // CARD 2: gruvbox palette preview
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 80
            color: Theme.bg1
            radius: 8
            border.color: Theme.bg2
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text { text: "SELECTED PALETTE (GRUVBOX DARK)"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }

                RowLayout {
                    spacing: 8
                    Repeater {
                        model: [Theme.grvRed, Theme.grvGreen, Theme.grvYellow, Theme.grvBlue, Theme.grvPurple, Theme.grvAqua, Theme.grvOrange]
                        delegate: Rectangle {
                            required property color modelData
                            Layout.fillWidth: true
                            height: 22
                            radius: 4
                            color: modelData
                        }
                    }
                }
            }
        }

        // action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: root.statusLog
                color: root.statusLog.startsWith("✓") ? Theme.grvGreen : (root.statusLog.startsWith("✕") ? Theme.grvRed : Theme.fg2)
                font.family: Theme.fontFamily
                font.pixelSize: 11
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 36
                radius: 6
                color: applyMouse.containsMouse ? Theme.hover : Theme.grvYellow
                border.color: Theme.grvYellow
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    //BUG it don work
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: "󰄬"; color: Theme.bg0; font.pixelSize: 13; font.bold: true }
                    Text { text: "apply"; color: Theme.bg0; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
                }

                MouseArea {
                    id: applyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveAndApply()
                }
            }
        }
    }
}