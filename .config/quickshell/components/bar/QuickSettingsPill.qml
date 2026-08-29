import "../.."

import "../../services"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    // net state reader
    // ora c'è un service

    id: qsPill
    property var screen: null

    property string netType: "DISCONNECTED"
    property string btStatus: "OFF"
    property int volume: 0
    property bool isMuted: false

    signal openControlCenterRequested()

    implicitHeight: 30
    implicitWidth: layout.implicitWidth + 24
    radius: height / 2
    color: Theme.darkgray

    

    // Audio
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readAudio.running = true
    }

    Process {
        id: readAudio

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            onRead: (data) => {
                let text = data.trim();
                qsPill.isMuted = text.includes("[MUTED]");
                let volMatch = text.match(/Volume:\s+([0-9.]+)/);
                if (volMatch && volMatch.length > 1)
                    qsPill.volume = Math.round(parseFloat(volMatch[1]) * 100);

            }
        }

    }

    // -- INTERFACCIA VISIVA --
    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 12

        Item {
            id: netContainer

            implicitWidth: netIcon.implicitWidth
            implicitHeight: netIcon.implicitHeight

            Text {
                id: netIcon

                anchors.centerIn: parent
                text: NetworkService.netType === "WIFI" ? "" : NetworkService.netType === "ETH" ? "" : ""
                font.pixelSize: 15
                color: NetworkService.netType === "DISCONNECTED" ? Theme.grvRed : "white"
            }

            MouseArea {
                id: netMouse

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: openNetworkManager.running = true
            }

            Process {
                id: openNetworkManager

                command: ["nm-connection-editor"]
            }

            CustomTooltip {
                anchorItem: netContainer
                show: netMouse.containsMouse
                text: NetworkService.tooltipText}

        }

        // Separatore
        Rectangle {
            width: 2
            height: 14
            color: "#444444"
        }

        // Icona Bluetooth
        Text {
            id: btComp

            text: BluetoothService.status === "OFF" ? "  " : ""
            font.pixelSize: 15
            color: BluetoothService.status === "CONNECTED" ? Theme.grvAqua : (BluetoothService.status === "ON" ? Theme.grvBlue : "#666666")

            MouseArea {
                id:btMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: openBlueman.running = true
                hoverEnabled: true
            }

            Process {
                id: openBlueman

                command: ["blueman-manager"]
            }
            CustomTooltip {
                anchorItem: btComp
                show: btMouse.containsMouse
                text: BluetoothService.tooltipText
            }

        }

        Rectangle {
            width: 2
            height: 14
            color: "#444444"
        }

        
        Item {
            implicitWidth: audioComp.implicitWidth
            implicitHeight: audioComp.implicitHeight

            RowLayout {
                id: audioComp

                spacing: 4

                Text {
                    text: qsPill.isMuted ? "" : (qsPill.volume > 50 ? "" : "")
                    font.pixelSize: 15
                    color: qsPill.isMuted ? "#666666" : Theme.fg0
                }

                Text {
                    text: qsPill.volume + "%"
                    font.pixelSize: 13
                    color: qsPill.isMuted ? "#666666" : Theme.fg0
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openPavucontrol.running = true
                }

                Process {
                    id: openPavucontrol

                    command: ["pavucontrol"]
                }

            }

        }

        // Separatore
        Rectangle {
            width: 2
            height: 14
            color: "#444444"
        }

        Item {
            implicitWidth: ccComp.implicitWidth
            implicitHeight: ccComp.implicitHeight

            Text {
                id: ccComp

                text: ""
                font.pixelSize: 15
                color: "#666666"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                //onClicked: qsPill.openControlCenterRequested()
                onClicked: ControlCenterService.toggleFrom(qsPill, qsPill.screen)
            }

        }

    }

}
