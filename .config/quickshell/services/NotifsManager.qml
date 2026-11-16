pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../"

/*!
    \qmltype NotifsManager
    \inherits Singleton
    \inqmlmodule services
    \brief central service managing dunst notification history, DND state, and dismiss actions
*/

Singleton {
    id: notifManager

    /*! \qmlproperty var NotifsManager::notificationsList
        array of parsed notification objects: { id, appName, summary, body, urgency, iconPath } */
    property var notificationsList: []
    readonly property int count: notificationsList.length
    property bool isPaused: false // true = DND is on

    // public methods for shell.qml
    function toggleDnd() {
        notifManager.isPaused = !notifManager.isPaused;
         Quickshell.execDetached(["dunstctl", "set-paused", "toggle"]);
    }

    function clearHistory() {
        notifManager.notificationsList = [];
        Quickshell.execDetached(["dunstctl", "history-clear"]);
    }

      function removeFromList(id) {
        notifManager.notificationsList = notifManager.notificationsList.filter(n => n.id !== id);
         Quickshell.execDetached(["dunstctl", "history-rm", String(id)]);
    }

    function refresh() {
        if (!dunstFetcher.running) dunstFetcher.running = true;
        if (!dndStatusProcess.running) dndStatusProcess.running = true;
    }

    // poll dunst history fetch
    Process {
        id: dunstFetcher

        command: ["sh", "-c", "dunstctl history | jq -c '.data[0]'"]
        running: false

        stdout: SplitParser {
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

    // periodic polling timer
    Timer {
        interval: (typeof Settings !== "undefined" && Settings.notifPollInterval) ? Settings.notifPollInterval : 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: notifManager.refresh()
    }

    
     /*Process {
        id: dndToggleProcess
        command: ["dunstctl", "set-paused", "toggle"]
    }*/

    // fetch DND status
    Process {
        id: dndStatusProcess
        command: ["dunstctl", "is-paused"]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                notifManager.isPaused = (line.trim() === "true");
            }
        }
    }

    /*Process {
        id: dunstClearer
        command: ["dunstctl", "history-clear"]
        onExited: dunstFetcher.running = true
    }

    Process {
        id: dunstRemover
        onExited: dunstFetcher.running = true
    }*/

}
