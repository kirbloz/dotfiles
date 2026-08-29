import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../.."

Rectangle {
    id: blRoot

    // Deve combaciare col "device" in config.json
    property string device: "amdgpu_bl1"
    property real brightness: 0.5 // 0..1

    color: Theme.bg2
    border.color: Theme.bg3
    border.width: 1
    radius: Theme.radius
    implicitHeight: content.implicitHeight + 16
    Layout.fillWidth: true

    // 1. Legge la luminosità attuale da brightnessctl
    Process {
        id: reader

        command: ["sh", "-c", "echo $(brightnessctl -d " + blRoot.device + " g) $(brightnessctl -d " + blRoot.device + " m)"]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(" ");
                if (parts.length === 2) {
                    const cur = parseFloat(parts[0]);
                    const max = parseFloat(parts[1]);
                    if (max > 0) blRoot.brightness = cur / max;
                }
            }
        }
    }

    // 2. Polling ogni 2s (sospeso mentre trascini lo slider)
    Timer {
        interval: 2000
        running: !slider.pressed
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!reader.running) reader.running = true;
        }
    }

    Process { id: setter }

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        // Icona Luminosità
        Text {
            text: "󰛩"
            color: Theme.fg1
            font.pixelSize: 18
        }

        // Slider stilizzato
        Slider {
            id: slider

            Layout.fillWidth: true
            from: 0.02 // Evita di spegnere del tutto lo schermo
            to: 1.0
            value: blRoot.brightness

            onMoved: {
                const pct = Math.round(value * 100);
                setter.command = ["sh", "-c", "brightnessctl -d " + blRoot.device + " set " + pct + "%"];
                setter.running = true;
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                implicitHeight: 6
                height: implicitHeight
                radius: 3
                color: Theme.bg3

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 3
                    color: Theme.grvYellow
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 14
                implicitHeight: 14
                radius: 7
                color: slider.pressed ? Theme.hover : Theme.fg0
                border.color: Theme.grvYellow
                border.width: 1
            }
        }

        // Indicatore Percentuale
        Text {
            text: Math.round((slider.pressed ? slider.value : blRoot.brightness) * 100) + "%"
            color: Theme.fgMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
            Layout.preferredWidth: 32
            horizontalAlignment: Text.AlignRight
        }
    }
}