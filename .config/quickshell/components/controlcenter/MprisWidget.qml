import "../.."
import "../../services"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: mprisRoot

    implicitHeight: MprisService.currentPlayer ? 100 : 0
    visible: MprisService.currentPlayer !== null
    color: Theme.bg2
    radius: Theme.radius
    border.color: Theme.bg3
    border.width: 1
    clip: true
    // Attiva il tracciamento della posizione solo quando il widget è visibile
    Component.onCompleted: MprisService.monitorPosition = true
    Component.onDestruction: MprisService.monitorPosition = false

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // Copertina Album
        Rectangle {
            id: coverContainer
            implicitWidth: 70
            implicitHeight: 70
            radius: Theme.radius
            color: Theme.bg3
            
            // Maschera i bordi arrotondati per l'immagine
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: coverContainer.width
                        height: coverContainer.height
                        radius: coverContainer.radius
                    }
                }
            }
            // Normalizzazione dell'URL
            readonly property string artUrl: {
                var url = MprisService.albumCover;
                if (!url || url === "")
                    return "";

                if (url.startsWith("/"))
                    return "file://" + url;

                return url;
            }


            Image {
                id: coverArt
                anchors.fill: parent
                source: coverContainer.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "󰎈"
                color: Theme.fgMuted
                font.pixelSize: 24
                visible: coverArt.status !== Image.Ready
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: MprisService.title !== "" ? MprisService.title : "Nothing playing rn.."
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: MprisService.artist !== "" ? MprisService.artist : "Unknown"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "󰒮"
                    color: (MprisService.canGoPrevious ?? true) ? Theme.fg1 : Theme.fgMuted
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (MprisService.canGoPrevious ?? true) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: MprisService.previous()
                    }

                }

                Text {
                    text: MprisService.playing ? "󰏤" : "󰐊"
                    color: Theme.grvYellow
                    font.pixelSize: 20

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.togglePlaying()
                    }

                }

                Text {
                    text: "󰒭"
                    color: (MprisService.canGoNext ?? true) ? Theme.fg1 : Theme.fgMuted
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (MprisService.canGoNext ?? true) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: MprisService.next()
                    }

                }

            }

        }

    }

}
