import qs
import "commons"
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell

/*!
    \qmltype MenuButton
    \inherits ColumnLayout
    \inqmlmodule components.commons
    \brief collapsible dropdown accordion menu executing shell commands from an actions list
*/

ColumnLayout {
    // header pulsante

    id: menuRoot

    property string label: ""
    /*! \qmlproperty var MenuButton::actions
        array of action objects: \c { label: string, command: string } */
    property var actions: []
    property bool expanded: false

    function execute(cmd: string) {
        console.log("[MenuButton] Execute:", cmd);

        if (!cmd) return;
        Quickshell.execDetached(["sh", "-c", cmd]);
        menuRoot.expanded = false;
    }

    spacing: 4
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop

    // ---- header ----
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        Layout.alignment: Qt.AlignTop
        implicitHeight: 34
        radius: Theme.radius || 8
        color: menuMouse.containsMouse ? Theme.hover : Theme.bg2
        border.color: Theme.bg3
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Text {
                text: menuRoot.label
                color: Theme.fg1
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: menuRoot.expanded ? "󰅃" : "󰅀"
                color: Theme.fgMuted
                font.family: Glyphs.fontFamily
                font.pixelSize: 14
            }

        }

        MouseArea {
            id: menuMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: menuRoot.expanded = !menuRoot.expanded
        }

    }

    // ---- dropdown actions container ----
    Rectangle {
        id: dropContainer

        readonly property int targetHeight: actionsCol.implicitHeight + 8

        Layout.fillWidth: true
        Layout.preferredHeight: menuRoot.expanded ? targetHeight : 0
        visible: Layout.preferredHeight > 0

        color: Theme.bg3
        radius: Theme.radius
        border.color: Theme.bg4
        border.width: 0

        clip: true

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Column {
            id: actionsCol

            width: parent.width - 8
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
                model: menuRoot.actions

                delegate: Rectangle {
                    required property var modelData

                    width: actionsCol.width
                    implicitHeight: 28
                    radius: Math.max(2, Theme.radius - 4)
                    color: itemMouse.containsMouse ? Theme.hover : "transparent"

                    Behavior on color { ColorAnimation { duration: 80 } }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.label
                        color: itemMouse.containsMouse ? Theme.fg1 : Theme.fg0
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menuRoot.execute(modelData.command)
                    }

                }

            }

        }

    }

}
