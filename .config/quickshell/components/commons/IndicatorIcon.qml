import "../.."
// components/commons/IndicatorIcon.qml
import QtQuick
import Quickshell.Io

Item {
    id: root

    required property string glyph
    property color glyphColor: Theme.fg0
    property string tooltipText: ""
    property var launchCommand: []

    signal clicked()
    signal rightClicked()

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label

        anchors.centerIn: parent
        text: root.glyph
        font.pixelSize: 15
        color: root.glyphColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                root.clicked()
                if (root.launchCommand.length > 0)
                    launcher.running = true
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked()
            }
        }
    }

    Process {
        id: launcher

        command: root.launchCommand
    }

    CustomTooltip {
        anchorItem: root
        show: mouse.containsMouse && root.tooltipText.length > 0
        text: root.tooltipText
    }

}
