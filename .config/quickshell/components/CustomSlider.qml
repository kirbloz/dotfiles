import QtQuick
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Layouts
import qs
import qs.services

/*!
    \qmltype CustomSlider
    \inherits RowLayout
    \inqmlmodule components.commons
    \brief reusable Gruvbox slider with optional leading icon, trailing readout, and detached command execution

    CustomSlider encapsulates a QtQuick Controls Slider styled to match the shell's theme; supports pure QML signal handling via \l moved or direct shell command dispatch by substituting \c "{}" inside \l setCommand
*/

RowLayout {
    id: sliderRoot

    /*! \qmlproperty string CustomSlider::label
        optional leading icon or text identifier displayed on the left */
    property string label: ""

    /*! \qmlproperty real CustomSlider::from
        minimum range value.
        defaults to 0 */
    property real from: 0

    /*! \qmlproperty real CustomSlider::to
        maximum range value
        defaults to 100. */
    property real to: 100

    /*! \qmlproperty real CustomSlider::stepSize
        step increment for discrete values
        defaults to 0 (continuous) */
    property real stepSize: 0

    /*! \qmlproperty real CustomSlider::value
        current slider position */
    property real value: 0

    /*! \qmlproperty bool CustomSlider::showValue
        whether to display the rounded numeric readout label on the right */
    property bool showValue: false

    /*! \qmlproperty string CustomSlider::unit
        suffix appended to the numeric readout (e.g. "%", "px") */
    property string unit: ""

    /*! \qmlproperty string CustomSlider::setCommand
        optional shell command executed on drag; "{}" is replaced with the rounded value */
    property string setCommand: ""

    /*! \qmlproperty bool CustomSlider::pressed
        read-only flag indicating whether the slider handle is actively dragged */
    readonly property bool pressed: controlSlider.pressed

    // emitted only on user interaction (drag / keyboard), like Slider.moved
    signal moved(real newValue)

    spacing: 10
    
    Text {
        visible: sliderRoot.label !== ""
        text: sliderRoot.label
        color: Theme.fg1
        font.pixelSize: 16
        Layout.preferredWidth: 20
        Layout.alignment: Qt.AlignVCenter
    }

    Slider {
        id: controlSlider

        Layout.fillWidth: true
        from: sliderRoot.from
        to: sliderRoot.to
        stepSize: sliderRoot.stepSize
        value: sliderRoot.value

        onMoved: {
            sliderRoot.moved(controlSlider.value);
            if (sliderRoot.setCommand !== "") {
                const cmd = sliderRoot.setCommand.replace("{}", Math.round(controlSlider.value));
                Quickshell.execDetached(["sh", "-c", cmd]);
            }
        }

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
                color: Theme.grvYellow
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
            border.color: Theme.grvYellow
            border.width: 1
        }
    }

    Text {
        visible: sliderRoot.showValue
        text: Math.round(controlSlider.value) + sliderRoot.unit
        color: Theme.fgMuted
        font.family: Theme.fontFamily
        font.pixelSize: 11
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 40
    }

    
}