import qs
import QtQuick
import Quickshell
import Quickshell.Io

/*!
    \qmltype QuickButton
    \inherits Rectangle
    \inqmlmodule components.commons
    \brief stateful action button that executes shell commands and polls background status

    QuickButton serves a dual purpose in panels and control centers:
    \list
        \li \b {Action Button}: executes a shell command or emits the \l clicked signal on primary click
        \li \b {Stateful Toggle}: if \l updateCommand is set, the button periodically executes the command and evaluates stdout (checking for \c {"true"}, \c {"1"}, or \c {"on"}) to reflect the active state visually via \l activeColor
    \endlist

    when a user triggers \l command, the button automatically triggers \l updateCommand upon process exit to guarantee zero-latency UI state synchronization

    Example usage:
    \code
    import "../components/commons"

    // Toggle Night Light / Gammastep
    QuickButton {
        text: "Night Light"
        command: "toggle-nightlight.sh"
        updateCommand: "is-nightlight-active.sh"
        pollInterval: 5000
    }
    \endcode
*/

Rectangle {
    id: btnRoot

    // ---- public properties ----
    property alias text: btnText.text
    /*! \qmlproperty string QuickButton::command
        shell command executed via \c {sh -c} when the button is clicked */
    property string command: ""
    /*! \qmlproperty string QuickButton::updateCommand
        optional shell command executed to query the button's active state
        expects \c {"true"}, \c {"1"}, or \c {"on"} to mark the button as active */
    property string updateCommand: ""
    /*! \qmlproperty int QuickButton::pollInterval
        polling interval in milliseconds used by the internal status checker timer
        defaults to \c {3000} (3 seconds); set to \c {0} to disable periodic polling */
    property int pollInterval: 3000
    property bool active: false

    // ---- geometry ----
    implicitHeight: 38
    radius: Theme.radius

    // ---- color palette ----
    property color activeColor: Theme.grvYellow 
    property color hoverColor: Theme.hover
    property color baseColor: Theme.bg2

    color: active ? activeColor : (mouseArea.containsMouse ? hoverColor : baseColor)
    
    // ---- signals ----
    signal clicked()

    Text {
        id: btnText

        anchors.centerIn: parent
        color: btnRoot.active ? Theme.bg0 : (mouseArea.containsMouse ? Theme.fg0 : Theme.fg1)
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: true
    }

    /*! \internal executes the primary action command and immediately refreshes status on exit */
    Process {
        id: cmdRunner

        onExited: statusRunner.running = updateCommand !== ""
    }

     /*! \internal queries system state and parses stout to update \c {active} property */
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
            btnRoot.clicked(); // emits native qml signal 
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
