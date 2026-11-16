import qs
import qs.services
import "../components/commons"
import "../components/controlcenter"
import "../components/dashboard"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris

/*!
    \qmltype ModernDashboard
    \inherits BasePopup
    \inqmlmodule modules
    \brief popup dashboard with hardware resource graphs and media player controls
*/

BasePopup {
    id: root

    readonly property var stats: SystemStats
    property int currentTab: 0
    readonly property int currentTabHeight: root.currentTab === 0 ? 110 : tabPerf.implicitHeight

    onOpened: MprisService.monitorPosition = true
    onClosed: MprisService.monitorPosition = false
    
    ipcTarget: "dashboard"
    panelWidth: 420
    // dynamic height between tabs
    panelHeight: headerRow.implicitHeight + 1 + root.currentTabHeight + (mainCol.spacing * 2) + 28

    Behavior on panelHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        id: mainCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 14
        spacing: 12

        // --- tabs row ---
        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                //{ name: "Overview", icon: "󰕮" },

                model: [{
                    "name": "Media",
                    "icon": "󰝚"
                }, {
                    "name": "Performance",
                    "icon": "󰓅"
                }]

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: root.currentTab === index ? Theme.grvYellow : (tabMa.containsMouse ? Theme.bg2 : Theme.bg1)
                    border.color: root.currentTab === index ? Theme.grvYellow : Theme.bg3
                    border.width: 1

                    // header
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: modelData.icon
                            color: root.currentTab === index ? Theme.bg0 : Theme.fg1
                            font.pixelSize: 13
                        }

                        Text {
                            text: modelData.name
                            color: root.currentTab === index ? Theme.bg0 : Theme.fg1
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: root.currentTab === index
                        }

                    }

                    MouseArea {
                        id: tabMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = index
                    }

                }

            }

            GlyphButton {
                glyph: Glyphs.close
                color: Theme.fgMuted
                pixelSize: 14
                onClicked: root.isOpen = false
            }

        }

        // --- separator ---
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.grvYellow
            opacity: 0.3
        }

        // tabs container
        // view
        StackLayout {
            id: tabViewport

            Layout.fillWidth: true
            implicitHeight: root.currentTabHeight
            currentIndex: root.currentTab

            // ==========================================
            // TAB 0: MEDIA PLAYER
            // ==========================================
            ColumnLayout {
                id: tabMedia
                Layout.fillWidth: true
                visible: root.currentTab === 0

                // grabs the first player (Spotify, Firefox, mpv...)
                readonly property MprisPlayer activePlayer: {
                    for (let p of Mpris.players.values) {
                        if (p.playbackState === MprisPlaybackState.Playing)
                            return p;

                    }
                    return Mpris.players.values[0] || null;
                }
                readonly property string coverUrl: {
                    const url = MprisService.albumCover;
                    if (!url || url === "")
                        return "";

                    if (url.startsWith("/"))
                        return "file://" + url;

                    return url;
                }

                spacing: 12
                width: parent.width

                // default view: active player
                MprisWidget {
                    Layout.fillWidth: true
                    visible: MprisService.currentPlayer !== null
                }

                // fallback card view
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 110
                    visible: MprisService.currentPlayer === null
                    color: "transparent"
                    radius: Theme.radius
                    border.color: "transparent"
                    border.width: 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 38
                            height: 38
                            radius: 19
                            color: Theme.bg2
                            border.color: Theme.bg3
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "󰝛"
                                color: Theme.fgMuted
                                font.family: Glyphs.fontFamily
                                font.pixelSize: 18
                            }

                        }

                        // text and subtext for fallback card
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No active media player"
                                color: Theme.fg1
                                font.family: Theme.fontFamily
                                font.bold: true
                                font.pixelSize: 12
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Start Firefox or mpv"
                                color: Theme.fgMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }

                        }

                    }

                }

            }

            // ==========================================
            // TAB 1: PERFORMANCE
            // ==========================================
            ColumnLayout {
                id: tabPerf
                Layout.fillWidth: true
                spacing: 10
                width: parent.width
                visible: root.currentTab === 1

                StatBar {
                    label: "CPU"
                    value: stats.cpuUsage
                    barColor: Theme.grvYellow
                }

                StatBar {
                    label: "GPU"
                    value: stats.gpuUsage
                    barColor: Theme.grvYellow
                }

                StatBar {
                    label: "RAM"
                    value: stats.ramUsage
                    valueText: stats.ramLabel
                    barColor: Theme.grvAqua
                }

                StatBar {
                    label: "VRAM"
                    value: stats.vramUsage
                    valueText: stats.vramLabel
                    barColor: Theme.grvAqua
                }

                StatBar {
                    label: "DISK /"
                    value: stats.diskUsage
                    valueText: stats.diskLabel
                    barColor: Theme.grvRed
                }

                // separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.bg2
                }

                NetworkStatsRow {
                    rx: stats.netRxKBs
                    tx: stats.netTxKBs
                }

                // FIXME check this actually works -> it does not
                RowLayout{
                    PowerMenu{}
                    PowerProfileMenu {}
                }

            }

        }

    }

}
