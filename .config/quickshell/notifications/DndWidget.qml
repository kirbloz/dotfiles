import QtQuick
import QtQuick.Layouts
import qs 

/*!
    \qmltype DndWidget
    \inqmlmodule notifications
    \inherits RowLayout
    \brief customized switch for do not disturb mode
*/

RowLayout {
    id: dndRoot

    property bool enabled: false
    signal toggled(bool value)

    Layout.fillWidth: true

    Text {
        text: "Do not disturb"
        color: Theme.fg1
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }

    Item {
        Layout.fillWidth: true
    }

    Rectangle {
        id: track

        implicitWidth: 40
        implicitHeight: 22
        radius: height / 2
        color: dndRoot.enabled ? Theme.hover : Theme.bg2
        border.color: dndRoot.enabled ? Theme.grvYellow : Theme.bg3
        border.width: 1

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: Theme.fg1
            anchors.verticalCenter: parent.verticalCenter
            x: dndRoot.enabled ? parent.width - width - 3 : 3

            Behavior on x {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                dndRoot.enabled = !dndRoot.enabled;
                dndRoot.toggled(dndRoot.enabled);
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}