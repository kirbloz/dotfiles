import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs

/*
    as of now, this is useful only when using the primary audio device. it cannot adapt or anything fancy
*/

Rectangle {
    id: volRoot

    property real volume: 0 // 0..1
    property bool muted: false

    color: Theme.bg2
    border.color: Theme.bg3
    border.width: 1
    radius: Theme.radius
    implicitHeight: content.implicitHeight + 16
    Layout.fillWidth: true

    // reads current volume 
    Process {
        id: reader
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: (line) => {
                const m = line.match(/Volume:\s*([\d.]+)/);
                if (m) volRoot.volume = parseFloat(m[1]);
                volRoot.muted = line.indexOf("MUTED") !== -1;
            }
        }
    }

    // polling timer, paused when setting slider
    Timer {
        interval: 1500
        running: !slider.pressed
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!reader.running) reader.running = true;
        }
    }

    // runs wpctl set-volume on setting slider
    Timer {
        id: setDebounce
        interval: 30
        repeat: false
        onTriggered: {
            setter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", slider.value.toFixed(2)];
            setter.running = true;
        }
    }

    Process { id: setter }

    // mute toggle
    Process {
        id: muteToggle
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: {
            if (!reader.running) reader.running = true;
        }
    }

    // ---- view ---- 
    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        Text {
            text: volRoot.muted ? "󰝟" : "󰕾"
            color: volRoot.muted ? Theme.grvRed : Theme.fg1
            font.pixelSize: 18

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (!muteToggle.running) muteToggle.running = true
            }
        }

        //TODO fix this
        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 1
            value: volRoot.volume

            onMoved: setDebounce.restart()

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
                    color: volRoot.muted ? Theme.fgMuted : Theme.grvYellow
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

        // percentage value
        Text {
            text: Math.round((slider.pressed ? slider.value : volRoot.volume) * 100) + "%"
            color: Theme.fgMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
            Layout.preferredWidth: 32
            horizontalAlignment: Text.AlignRight
        }
    }
}