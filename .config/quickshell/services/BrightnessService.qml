pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/*!
    \qmltype BrightnessService
    \inherits Singleton
    \inqmlmodule services
    \brief central brightness management service interfacing with brightnessctl
*/

Singleton {
    id: root

    property int percentage: 50
    property string device: "amdgpu_bl1"
    // this file is... giving me a headache
    property string scriptPath: "/run/user/1000/brightness/brightness.state" 
    property bool isPopupOpen: false

    function setPercentage(value) {
        const clamped = Math.max(2, Math.min(100, Math.round(value)));
        root.percentage = clamped; 
        Quickshell.execDetached(["brightnessctl", "-d", root.device, "set", clamped + "%"]);
    }

    function increase() {
        setPercentage(root.percentage + 5);
    }

    function decrease() {
        setPercentage(root.percentage - 5);
    }

    Process {
        id: readProc
        command: ["sh", "-c", "echo $(brightnessctl -d " + root.device + " g) $(brightnessctl -d " + root.device + " m)"]
        running: false

        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(" ");
                if (parts.length === 2) {
                    const cur = parseFloat(parts[0]);
                    const max = parseFloat(parts[1]);
                    if (max > 0) root.percentage = Math.round((cur / max) * 100);
                }
            }
        }
    }

    // refresh everyh 10s
    Timer {
        interval: 10000
        running: isPopupOpen
        repeat: true
        onTriggered: root.refresh()
    }

}
