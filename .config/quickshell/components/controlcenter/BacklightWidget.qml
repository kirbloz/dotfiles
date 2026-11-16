import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs

/*!
    \qmltype BackightWidget
    \inherits Rectangle
    \inqmlmodule components.controlcenter
    \brief reads from service and displays current backlight status and offers a slider to adjust value

    hardware backlight interface has to be specified

    \note service works only for integrated screens on laptops; TODO add ddutil support

    Example usage:
    \code
    import "../components/controlcenter"

    BacklightWidget {
        device: "amdgpu_bl1"
        Layout.fillWidth: true
    }
    \endcode
    */

Rectangle {
    id: blRoot

    // TODO remove hardcoded idiot
    /*!
        \qmlproperty string BacklightWidget::device
        target backlight device name as recognized by \c brightnessctl (e.g., \c {"amdgpu_bl1"}, \c {"intel_backlight"})
        defaults to \c {"amdgpu_bl1"}
    */
    property string device: "amdgpu_bl1"
     /*!
        \qmlproperty real BacklightWidget::brightness
        normalized brightness level represented as a floating-point value between \c {0.0} (0%) and \c {1.0} (100%)
        defaults to \c {0.5} (50%)
    */
    property real brightness: 0.5 // 0..1

    // ---- style and geometry ----
    color: Theme.bg2
    border.color: Theme.bg3
    border.width: 1
    radius: Theme.radius
    implicitHeight: content.implicitHeight + 16
    Layout.fillWidth: true

    /*! \internal reads current and maximum brightness from brightnessctl and computes the normalized ratio */
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

    /*! \internal periodic 2s polling timer; pauses during slider drag */
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

    // ---- user interface layout ----
    RowLayout {
        id: content

        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        // brightness icon
        Text {
            text: "󰛩"
            color: Theme.fg1
            font.pixelSize: 18
        }

        // interactive slider
        Slider {
            id: slider

            Layout.fillWidth: true
            from: 0.02 // clamped to 2% to avoid turning off screen
            to: 1.0
            value: blRoot.brightness

            onMoved: {
                const pct = Math.round(value * 100);
                setter.command = ["sh", "-c", "brightnessctl -d " + blRoot.device + " set " + pct + "%"];
                setter.running = true;
            }

            // slider background
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                implicitHeight: 6
                height: implicitHeight
                radius: 3
                color: Theme.bg3

                // active filled bar
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 3
                    color: Theme.grvYellow
                }
            }

            // slider draggable handle
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

        // percentage text label
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