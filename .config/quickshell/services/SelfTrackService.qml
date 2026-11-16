// quickshell/services/SelfTrackService.qml — backend & polling
pragma Singleton
import ".."
import "../scripts/SelfTrack.js" as ST
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property bool monitorEnabled: (typeof Settings !== "undefined" && Settings && Settings.selftrackEnabled !== undefined) ? Settings.selftrackEnabled : true
    // data exposed to UI
    property string dateStr: _todayStr()
    property int dayActiveMs: 0
    property int dayIdleMs: 0
    property int weekMs: 0
    property string weekLabel: ""
    property int monthMs: 0
    property string monthLabel: ""
    property var appsModel: []
    property var sessionsModel: []
    property var pagesModel: []
    property string pageApp: ""
    property bool loading: false
    property string errorText: ""

    // data for UI updated in background
    property int todayActiveMs: 0
    readonly property string todayText: ST.formatShort(root.todayActiveMs)

    property real _refreshStartMs: 0

    readonly property string selftrackBin: {
        var fromPath = String(StandardPaths.findExecutable("selftrack") ?? "").replace(/^file:\/\//, "");
        if (fromPath !== "") return fromPath;

        var home = String(Quickshell.env("HOME") ?? "").replace(/^file:\/\//, "");
        if (home !== "") return home + "/.cargo/bin/selftrack";

        return "selftrack";
    }

    // navigation and control

    function _todayStr() { return ST.todayStr(); }
    function _isToday() { return root.dateStr === root._todayStr(); }

    function shiftDate(days) {
        var p = root.dateStr.split("-");
        var d = new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]));
        d.setDate(d.getDate() + days);
        root.dateStr = d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
        root.pageApp = "";
        root.pagesModel = [];
        root.refresh();
    }

    function goToday() {
        root.dateStr = root._todayStr();
        root.pageApp = "";
        root.pagesModel = [];
        root.refresh();
    }

    function refresh() {
        if (!root.monitorEnabled || fetchProc.running) return;
        root.loading = true;
        root.errorText = "";
        root._refreshStartMs = Date.now();
        loadingMinTimer.stop();
        fetchProc._todayOnly = false;
        fetchProc.command = [root.selftrackBin, "export", "--date", root.dateStr];
        fetchProc.running = true;
    }

    function refreshToday() {
        if (!root.monitorEnabled || fetchProc.running) return;
        fetchProc._todayOnly = true;
        fetchProc.command = [root.selftrackBin, "export", "--date", root._todayStr()];
        fetchProc.running = true;
    }

    function refreshPages(app) {
        if (fetchPagesProc.running) return;
        if (root.pageApp === app) {
            root.pageApp = "";
            root.pagesModel = [];
            return;
        }
        fetchPagesProc.command = [root.selftrackBin, "export", "--date", root.dateStr, "--app", app];
        fetchPagesProc._wantApp = app;
        fetchPagesProc.running = true;
    }

    function _finishLoading() {
        var wait = 700 - (Date.now() - root._refreshStartMs);
        if (wait > 0) {
            loadingMinTimer.interval = wait;
            loadingMinTimer.restart();
        } else {
            root.loading = false;
        }
    }

    function _applyExport(obj) {
        if (typeof obj !== "object" || obj === null) return;
        if (obj.date === root._todayStr() && obj.day)
            root.todayActiveMs = obj.day.active_ms;

        root.dayActiveMs = obj.day ? obj.day.active_ms : 0;
        root.dayIdleMs = obj.day ? obj.day.idle_ms : 0;
        root.weekMs = obj.week ? obj.week.active_ms : 0;
        root.weekLabel = obj.week ? (obj.week.from + " – " + obj.week.to) : "";
        root.monthMs = obj.month ? obj.month.active_ms : 0;
        root.monthLabel = obj.month ? root.dateStr.substring(0, 7) : "";
        root.appsModel = obj.apps ? obj.apps : [];
        root.sessionsModel = obj.sessions ? obj.sessions : [];
    }

    onMonitorEnabledChanged: {
        if (monitorEnabled) {
            root.refresh();
            pollTimer.running = true;
        } else {
            pollTimer.running = false;
            fetchProc.running = false;
            fetchPagesProc.running = false;
        }
    }

    // first launch timer
    Timer {
        interval: 1500
        running: true
        repeat: false
        onTriggered: if (root.monitorEnabled) root.refresh()
    }

    // polling every 60s
    Timer {
        id: pollTimer
        interval: 60000
        running: root.monitorEnabled
        repeat: true
        onTriggered: {
            if (root._isToday()) root.refresh();
            else root.refreshToday();
        }
    }

    Timer {
        id: loadingMinTimer
        repeat: false
        onTriggered: root.loading = false
    }

    // IO
    Process {
        id: fetchProc
        property bool _todayOnly: false
        onExited: (code) => {
            running = false;
            if (fetchProc._todayOnly) {
                root.loading = false;
            } else {
                if (code !== 0 && root.errorText === "")
                    root.errorText = "selftrack failed (" + code + ")";
                if (root.loading) root._finishLoading();
            }
        }
        stdout: StdioCollector {
            id: fetchCollector
            waitForEnd: true
            onStreamFinished: {
                var text = fetchCollector.text.trim();
                var todayOnly = fetchProc._todayOnly;
                if (text === "") {
                    if (!todayOnly) root.errorText = "Empty response";
                } else {
                    try {
                        var obj = JSON.parse(text);
                        if (todayOnly) {
                            if (obj.date === root._todayStr() && obj.day)
                                root.todayActiveMs = obj.day.active_ms;
                        } else {
                            root._applyExport(obj);
                        }
                    } catch (e) {
                        if (!todayOnly) root.errorText = "Parse error";
                    }
                }
                if (todayOnly) root.loading = false;
                else root._finishLoading();
            }
        }
    }

    Process {
        id: fetchPagesProc
        property string _wantApp: ""
        onExited: running = false
        stdout: StdioCollector {
            id: pagesCollector
            waitForEnd: true
            onStreamFinished: {
                var text = pagesCollector.text.trim();
                if (text === "") return;
                try {
                    var obj = JSON.parse(text);
                    if (obj.page_app === fetchPagesProc._wantApp) {
                        root.pageApp = obj.page_app ? obj.page_app : "";
                        root.pagesModel = obj.pages ? obj.pages : [];
                    }
                } catch (e) {
                    console.warn("[SelfTrackService] pages parse error:", e);
                }
            }
        }
    }
}