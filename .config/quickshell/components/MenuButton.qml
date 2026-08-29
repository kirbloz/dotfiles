import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

// Un pulsante che espande una tendina di azioni sotto di sé, come le
// voci "menu#power-profile" / "menu#power" definite in config.json
ColumnLayout {
    id: menuRoot

    property string label: ""
    // Array di { label: "...", command: "..." }
    property var actions: []

    property bool expanded: false

    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 34
        radius: Theme.radius
        color: menuMouse.containsMouse ? Theme.hover : Theme.bg2
        border.color: Theme.bg3
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8

            Text {
                text: menuRoot.label
                color: Theme.fg1
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: menuRoot.expanded ? "󰅃" : "󰅀"
                color: Theme.fgMuted
                font.pixelSize: 12
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

    Rectangle {
        Layout.fillWidth: true
        color: Theme.bg3
        radius: Theme.radius
        border.color: Theme.bg4
        border.width: 1
        clip: true
        

        Column {
            id: actionsCol
            width: parent.width
            
            

            Repeater {
                model: menuRoot.actions
                delegate: Rectangle {
                    width: actionsCol.width
                    implicitHeight: 30
                    color: itemMouse.containsMouse ? Theme.hover : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: Theme.fg1
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Process { id: runner }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            runner.command = ["sh", "-c", modelData.command];
                            runner.running = true;
                            menuRoot.expanded = false;
                        }
                    }
                }
            }
        }
    }
}
