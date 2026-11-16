import qs
import qs.services
import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    width: 25 + 5
    height: 25 + 4
    color: Theme.grvOrangeDim
    radius: Theme.workspaceRadius

    Process {
        id: logoutProcess

        command: ["wlogout"]
    }

    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: Theme.darkgray // @backgroundlight
        font.pixelSize: 20
        y: -25
    }

    MouseArea {
        anchors.fill: parent
        onClicked: logoutProcess.running = true
        cursorShape: Qt.PointingHandCursor
    }

}
