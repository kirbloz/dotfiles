import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."
import qs
import qs.services
import "../../components/dashboard"
import "../../components/commons"
import "../../components/core"

/*!
    \qmltype SystemInfoView
    \inherits Flickable
    \inqmlmodule settings
    \brief system specification and resource usage page for SettingsWindow
*/

Flickable {
    id: root

    // data comes from sysinfo.sh script (key=value lines)
    property string scriptPath: Quickshell.env("HOME") + Settings.sysinfoScriptPath
    property var info: ({})

    contentWidth: width
    contentHeight: contentCol.implicitHeight + 20
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    function parse(txt) {
        const o = {};
        for (const line of txt.split("\n")) {
            const i = line.indexOf("=");
            if (i > 0)
                o[line.slice(0, i)] = line.slice(i + 1).trim();
        }
        root.info = o;
    }

    function val(key) {
        const v = root.info[key];
        return (v === undefined || v === "") ? "—" : v;
    }

    Process {
        id: infoProc
        command: ["bash", root.scriptPath]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    // static info: reads only while visible on opening
    Timer {
        interval: 0
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!infoProc.running)
                infoProc.running = true;
        }
    }

    // ---- content ----
    ColumnLayout {
        id: contentCol
        width: root.width - 12
        spacing: 16

        RowLayout {
            spacing: 8

            Text {
                text: "󰋼"
                color: Theme.grvYellow
                font.family: Glyphs.fontFamily
                font.pixelSize: 18
            }

            Text {
                text: "System Information"
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 15
            }
        }

        // CARD 1: system
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: sysCol.implicitHeight + 28
            color: Theme.bg1
            radius: 8
            border.color: Theme.bg2
            border.width: 1

            ColumnLayout {
                id: sysCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    text: "SYSTEM"
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }

                InfoRow { key: "OS"; value: root.val("os") }
                InfoRow { key: "Kernel"; value: root.val("kernel") }
                InfoRow { key: "Hostname"; value: root.val("host") }
                InfoRow { key: "Uptime"; value: root.val("uptime") }
                InfoRow { key: "Session"; value: root.val("session") }
                InfoRow { key: "Packages"; value: root.info.packages ? root.info.packages + " (pacman)" : "—" }
                InfoRow { key: "Quickshell"; value: root.val("shell") }
            }
        }

        // CARD 2: hardware
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: hwCol.implicitHeight + 28
            color: Theme.bg1
            radius: 8
            border.color: Theme.bg2
            border.width: 1

            ColumnLayout {
                id: hwCol

                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    text: "HARDWARE"
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }

                InfoRow { key: "CPU"; value: root.val("cpu") }
                InfoRow { key: "Threads"; value: root.val("cores") }
                InfoRow { key: "GPU"; value: root.val("gpu") }
            }
        }

        // CARD 3: realtime resources
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: resCol.implicitHeight + 28
            color: Theme.bg1
            radius: 8
            border.color: Theme.bg2
            border.width: 1

            ColumnLayout {
                id: resCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Text {
                    text: "RESOURCES"
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }

                UsageBar {
                    title: "CPU"
                    fraction: SystemStats.cpuUsage
                    accent: Theme.grvOrange
                }

                UsageBar {
                    title: "Memory"
                    detail: SystemStats.ramLabel
                    fraction: SystemStats.ramUsage
                    accent: Theme.grvAqua
                }

                UsageBar {
                    title: "GPU"
                    fraction: SystemStats.gpuUsage
                    accent: Theme.grvPurple
                }

                UsageBar {
                    visible: SystemStats.vramLabel !== "-- / -- GB"
                    title: "VRAM"
                    detail: SystemStats.vramLabel
                    fraction: SystemStats.vramUsage
                    accent: Theme.grvBlue
                }

                UsageBar {
                    title: "Disk (home)"
                    detail: SystemStats.diskLabel
                    fraction: SystemStats.diskUsage
                    accent: Theme.grvYellow
                }

                InfoRow {
                    // TODO unify this with components.dashboard.NetStatsRow
                    key: "Network"
                    value: "\u2193 " + SystemStats.netRxFormatted + "    \u2191 " + SystemStats.netTxFormatted
                }
            }
        }
    }
}
