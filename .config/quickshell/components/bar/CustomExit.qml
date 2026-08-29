import "../../"
import QtQuick
import Quickshell.Io

Rectangle {
    id: root

    width: 25+4
    height: 25+3
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
    }

    MouseArea {
        anchors.fill: parent
        onClicked: logoutProcess.running = true
    }

}
