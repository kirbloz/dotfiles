import qs
import QtQuick
import QtQuick.Layouts

/*!
    \qmltype StatBar
    \inherits RowLayout
    \inqmlmodule components.dashboard
    \brief read-only animated progress bar
*/
RowLayout {
    id: barRoot

    /*! \qmlproperty string StatBar::label
        metric label displayed on the left */
    property string label: ""
    property real value: 0 // 0..1
    /*! \qmlproperty string StatBar::valueText
        text value displayed on the right
        defaults to percentage string */
    property string valueText: Math.round(value * 100) + "%"
     /*! \qmlproperty color StatBar::barColor
        fill color of the active progress level
        defaults to Theme.grvYellow */
    property color barColor: Theme.grvYellow

    Layout.fillWidth: true
    spacing: 12

    // ---- metric label ----
    Text {
        text: barRoot.label
        color: Theme.fg1
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: 11
        Layout.preferredWidth: 55
        elide: Text.ElideRight
    }

    // ---- bar and fill ----
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 8
        radius: 4
        color: Theme.bg3

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, barRoot.value))
            height: parent.height
            radius: 4
            color: barRoot.barColor

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    // ---- metric value ----
    Text {
        text: barRoot.valueText
        color: Theme.fgMuted
        font.family: Theme.fontFamily
        font.pixelSize: 11
        Layout.preferredWidth: 80
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
    }

}
