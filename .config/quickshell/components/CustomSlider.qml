import QtQuick
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: sliderRoot

    property string label: "󰕾"
    property real value: 0
    property string setCommand: ""

    spacing: 10
    Layout.fillWidth: true

    Text {
        text: sliderRoot.label
        color: Theme.fg1
        font.pixelSize: 16
        Layout.preferredWidth: 20
    }

    Slider {
        id: controlSlider
        Layout.fillWidth: true
        from: 0
        to: 100
        value: sliderRoot.value

        // Esponiamo esplicitamente il segnale 'moved' richiesto da ActionCenterPanel
    signal moved()

    // Invociamo il segnale 'moved' ogni volta che l'utente trascina lo slider
    onMoved: {
        if (sliderRoot.setCommand !== "") {
                sliderProc.command = ["sh", "-c", sliderRoot.setCommand.replace("{}", Math.round(value))]
                sliderProc.running = true
            }
        // Mantiene il comportamento standard di QtQuick Controls 2
    }

    // Collega l'evento di interazione dell'utente al segnale custom
    onValueChanged: {
        if (control.pressed) {
            control.moved();
        }
    }

        // Personalizzazione visiva stile Gruvbox
        background: Rectangle {
            x: controlSlider.leftPadding
            y: controlSlider.topPadding + controlSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 6
            width: controlSlider.availableWidth
            height: implicitHeight
            radius: 3
            color: Theme.bg3

            Rectangle {
                width: controlSlider.visualPosition * parent.width
                height: parent.height
                color: Theme.yellow
                radius: 3
            }
        }

        handle: Rectangle {
            x: controlSlider.leftPadding + controlSlider.visualPosition * (controlSlider.availableWidth - width)
            y: controlSlider.topPadding + controlSlider.availableHeight / 2 - height / 2
            implicitWidth: 14
            implicitHeight: 14
            radius: 7
            color: controlSlider.pressed ? Theme.hover : Theme.fg0
            border.color: Theme.yellow
            border.width: 1
        }

        /*onMoved: {
            if (sliderRoot.setCommand !== "") {
                sliderProc.command = ["sh", "-c", sliderRoot.setCommand.replace("{}", Math.round(value))]
                sliderProc.running = true
            }
        }*/
    }

    Process {
        id: sliderProc
    }
}