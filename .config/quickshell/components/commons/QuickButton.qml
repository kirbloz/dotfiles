import "../.."
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: btnRoot

    property alias text: btnText.text
    property string command: ""
    property string updateCommand: ""
    property int pollInterval: 3000
    property bool active: false

    implicitHeight: 38
    radius: Theme.radius
    //color: active ? Theme.grvYellow : (mouseArea.containsMouse ? Theme.hover : Theme.bg2)

    property color activeColor: Theme.grvYellow 
    property color hoverColor: Theme.hover
    property color baseColor: Theme.bg2
    color: active ? activeColor : (mouseArea.containsMouse ? hoverColor : baseColor)
    signal clicked()

    Text {
        id: btnText

        anchors.centerIn: parent
        color: btnRoot.active ? Theme.bg0 : (mouseArea.containsMouse ? Theme.fg0 : Theme.fg1)
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: true
    }

    Process {
        id: cmdRunner

        onExited: statusRunner.running = updateCommand !== ""
    }

    Process {
        id: statusRunner

        command: ["sh", "-c", btnRoot.updateCommand]
        running: false

        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim();
                btnRoot.active = (v === "true" || v === "1" || v === "on");
            }
        }

    }

    Timer {
        interval: btnRoot.pollInterval
        running: btnRoot.updateCommand !== "" && btnRoot.pollInterval > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: statusRunner.running = true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            btnRoot.clicked(); // 🟢 EMETTE IL SEGNALE PER IL QML PURO
            if (btnRoot.command !== "") {
                cmdRunner.command = ["sh", "-c", btnRoot.command];
                cmdRunner.running = true;
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 60
        }

    }

}
