import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: notifManager

    property var notificationsList: []

    // public methods for shell.qml
    function toggleDnd() {
        dndToggleProcess.running = true;
    }

    function clearHistory() {
        notifManager.notificationsList = [];
        dunstClearer.running = true;
    }

    // poll dunst history
    Process {
        id: dunstFetcher

        command: ["sh", "-c", "dunstctl history | jq -c '.data[0]'"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (!data || data.trim() === "")
                    return ;

                try {
                    const parsed = JSON.parse(data.trim());
                    const raw = Array.isArray(parsed) ? parsed : [];
                    // dunstctl returns fields wrapped in DBus variant format: 
                    // {"type": "s", "data": "value"}
                    notifManager.notificationsList = raw.map((n) => {
                        return ({
                            "id": n.id ? n.id.data : 0,
                            "appName": n.appname ? n.appname.data : "Sistema",
                            "summary": n.summary ? n.summary.data : "",
                            "body": n.body ? n.body.data : "",
                            "urgency": n.urgency ? n.urgency.data : "NORMAL",
                            "iconPath": n.icon_path ? n.icon_path.data : ""
                        });
                    });
                } catch (e) {
                    notifManager.notificationsList = [];
                }
            }
        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dunstFetcher.running = true
    }

    // DND
    Process {
        id: dndToggleProcess

        command: ["sh", "-c", "dunstctl set-paused toggle && pkill -RTMIN+8 waybar"]
        running: false
    }

    // Clear
    Process {
        id: dunstClearer

        command: ["dunstctl", "history-clear"]
        running: false
        onExited: dunstFetcher.running = true
    }
    // dunstctl doesnt support single notif delete
    // this is purely local, the notif re-appears on next poll
    function removeFromList(id) {
        notifManager.notificationsList = notifManager.notificationsList.filter(n => n.id !== id);
    }

}
