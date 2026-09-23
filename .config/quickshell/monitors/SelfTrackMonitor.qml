import ".."
import "../scripts/SelfTrack.js" as ST
import QtCore
import QtQuick
import QtQuick.Layouts
// ============================================================
// quickshell/monitors/SelfTrackMonitor.qml — монітор трекера часу: опитує selftrack export, тримає моделі дня
// ============================================================
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property QtObject settings
    readonly property color primary: Theme.grvYellow
    readonly property color secondary: Theme.grvAqua
    readonly property color accent: Theme.grvOrange
    readonly property color background: Theme.bg0
    readonly property color text: Theme.fg1
    readonly property color subtext: Theme.fg4
    readonly property color border: Theme.bg2
    readonly property color active: Theme.grvGreen
    readonly property color inactive: Theme.grvRed
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeNormal: 12
    readonly property int fontSizeLarge: 14
    readonly property int fontTitle: 16
    readonly property int padding: 8

    // (YYYY-MM-DD)
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
    property real _refreshStartMs: 0
    property string errorText: ""
    readonly property string selftrackBin: {
        var fromPath = String(StandardPaths.findExecutable("selftrack") ?? "").replace(/^file:\/\//, "");
        if (fromPath !== "")
            return fromPath;

        var home = String(Quickshell.env("HOME") ?? "").replace(/^file:\/\//, "");
        if (home !== "")
            return home + "/.cargo/bin/selftrack";

        return "selftrack";
    }
    property int todayActiveMs: 0
    readonly property string todayText: ST.formatShort(root.todayActiveMs)
    property bool monitorEnabled: settings ? settings.selftrackEnabled : false


// --- Proprietà e Funzioni per la Timeline (Ex SelfTrackPopup) ---
    property real zoomStartMs: 0
    property real zoomLenMs: 86400000
    readonly property bool zoomed: root.zoomLenMs < 86400000
    property string hoverInfo: ""
    
    readonly property var appColors: [Theme.grvGreen, Theme.grvBlue, Theme.grvYellow, Theme.grvPurple, Theme.grvOrange, Theme.grvAqua]

    onDateStrChanged: zoomReset()

    function zoomReset() {
        root.zoomStartMs = 0;
        root.zoomLenMs = 86400000;
    }

    function wheelZoom(frac, up) {
        var dayLen = 86400000;
        var minLen = 60000;
        if (up && root.zoomLenMs <= minLen) return;
        if (!up && root.zoomLenMs >= dayLen) return;
        var newLen = Math.max(minLen, Math.min(dayLen, root.zoomLenMs * (up ? 1 / 1.3 : 1.3)));
        var tCursor = root.zoomStartMs + frac * root.zoomLenMs;
        root.zoomStartMs = Math.max(0, Math.min(dayLen - newLen, tCursor - frac * newLen));
        root.zoomLenMs = newLen;
        if (newLen >= dayLen) root.zoomReset();
    }

    function stripClickAt(frac) {
        var dayLen = 86400000;
        if (root.zoomLenMs >= dayLen) {
            var h = Math.max(0, Math.min(23, Math.floor(frac * 24)));
            root.zoomStartMs = h * 3600000;
            root.zoomLenMs = 3600000;
        } else {
            var rel = root.zoomStartMs + frac * root.zoomLenMs;
            root.zoomStartMs = Math.max(0, Math.min(dayLen - root.zoomLenMs, rel - root.zoomLenMs / 2));
        }
    }

    function hoverAt(x) {
        var frac = Math.max(0, Math.min(1, x / timelineTrack.width));
        var base = ST.dayStartMs(root.dateStr);
        var t = base + root.zoomStartMs + frac * root.zoomLenMs;
        var best = null;
        var count = 0;
        for (var i = 0; i < root.sessionsModel.length; i++) {
            var s = root.sessionsModel[i];
            if (s.start_ms <= t && t < s.end_ms) {
                count++;
                if (!best || (s.end_ms - s.start_ms) < (best.end_ms - best.start_ms)) best = s;
            }
        }
        if (!best) {
            root.hoverInfo = ST.formatClock(t) + "  — no data —";
            return;
        }
        var txt = ST.formatClock(best.start_ms) + "–" + ST.formatClock(best.end_ms) + "  ";
        if (best.idle) {
            txt += "idle";
        } else {
            var title = ST.cleanTitle(best.title);
            txt += best.app + (title !== "" ? " • " + title : "");
        }
        if (count > 1) txt += "  (+" + (count - 1) + " overlapping)";
        root.hoverInfo = txt;
    }

    function tickLabels() {
        if (root.zoomLenMs >= 86400000) return ["00", "06", "12", "18", "24"];
        var base = ST.dayStartMs(root.dateStr);
        var showSec = root.zoomLenMs <= 300000;
        var labels = [];
        for (var i = 0; i <= 4; i++) {
            var t = base + root.zoomStartMs + root.zoomLenMs * i / 4;
            labels.push(showSec ? ST.formatClockS(t) : ST.formatClock(t));
        }
        return labels;
    }

    function zoomRangeText() {
        var base = ST.dayStartMs(root.dateStr);
        return ST.formatClock(base + root.zoomStartMs) + "–" + ST.formatClock(base + root.zoomStartMs + root.zoomLenMs);
    }

    function appColor(app) {
        return root.appColors[ST.appColorIndex(app, root.appColors.length)];
    }

    // --- Logica e Aggiornamento ---

    function _finishLoading() {
        var wait = 700 - (Date.now() - root._refreshStartMs);
        if (wait > 0) {
            loadingMinTimer.interval = wait;
            loadingMinTimer.restart();
        } else {
            root.loading = false;
        }
    }

    function _todayStr() {
        return ST.todayStr();
    }

    function _isToday() {
        return root.dateStr === root._todayStr();
    }

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
        if (!root.monitorEnabled)
            return ;

        if (fetchProc.running)
            return ;

        root.loading = true;
        root.errorText = "";
        root._refreshStartMs = Date.now();
        loadingMinTimer.stop();
        fetchProc._todayOnly = false;
        fetchProc.command = [root.selftrackBin, "export", "--date", root.dateStr];
        fetchProc.running = true;
    }

    function refreshToday() {
        if (!root.monitorEnabled)
            return ;

        if (fetchProc.running)
            return ;

        fetchProc._todayOnly = true;
        fetchProc.command = [root.selftrackBin, "export", "--date", root._todayStr()];
        fetchProc.running = true;
    }

    function refreshPages(app) {
        if (fetchPagesProc.running)
            return ;

        if (root.pageApp === app) {
            root.pageApp = "";
            root.pagesModel = [];
            return ;
        }
        fetchPagesProc.command = [root.selftrackBin, "export", "--date", root.dateStr, "--app", app];
        fetchPagesProc._wantApp = app;
        fetchPagesProc.running = true;
    }

    function collapsePages() {
        root.pageApp = "";
        root.pagesModel = [];
    }

    function _applyExport(obj) {
        if (typeof obj !== "object" || obj === null)
            return ;

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

    Timer {
        interval: 1500
        running: true
        repeat: false
        onTriggered: {
            if (root.monitorEnabled)
                root.refresh();

        }
    }

    Timer {
        id: pollTimer

        interval: 60000
        running: root.monitorEnabled
        repeat: true
        onTriggered: {
            if (root._isToday())
                root.refresh();
            else
                root.refreshToday();
        }
    }

    Timer {
        id: loadingMinTimer

        repeat: false
        onTriggered: root.loading = false
    }

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

                if (root.loading)
                    root._finishLoading();

            }
        }

        stdout: StdioCollector {
            id: fetchCollector

            waitForEnd: true
            onStreamFinished: {
                var text = fetchCollector.text.trim();
                var todayOnly = fetchProc._todayOnly;
                if (text === "") {
                    if (!todayOnly)
                        root.errorText = "Empty response";

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
                        if (!todayOnly)
                            root.errorText = "Parse error";

                    }
                }
                if (todayOnly)
                    root.loading = false;
                else
                    root._finishLoading();
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
                if (text === "")
                    return ;

                try {
                    var obj = JSON.parse(text);
                    if (obj.page_app === fetchPagesProc._wantApp) {
                        root.pageApp = obj.page_app ? obj.page_app : "";
                        root.pagesModel = obj.pages ? obj.pages : [];
                    }
                } catch (e) {
                    console.warn("[SelfTrack] pages parse fail", e);
                }
            }
        

        }

    }
    
   // ============================================================
    // INTERFACCIA GRAFICA (Visualizzazione Dati)
    // ============================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // --- Заголовок: Header ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Time Tracking"
                color: Theme.grvGreen
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: 24; implicitHeight: 24; radius: 6
                color: navPrevMa.containsMouse ? Theme.bg2 : Theme.bg1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "‹"; color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 16 }
                MouseArea { id: navPrevMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.shiftDate(-1) }
            }

            Text {
                text: root.dateStr
                color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 12; font.bold: true
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.goToday() }
            }

            Rectangle {
                implicitWidth: 24; implicitHeight: 24; radius: 6
                color: navNextMa.containsMouse ? Theme.bg2 : Theme.bg1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "›"; color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 16 }
                MouseArea { id: navNextMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.shiftDate(1) }
            }

            Rectangle {
                implicitWidth: 24; implicitHeight: 24; radius: 6
                color: refreshMa.containsMouse ? Theme.bg2 : Theme.bg1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent; text: "⟳"; color: Theme.gray; font.family: Theme.fontFamily; font.pixelSize: 13
                    RotationAnimator on rotation { running: root.loading; loops: Animation.Infinite; from: 0; to: 360; duration: 800 }
                }
                MouseArea { id: refreshMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.refresh() }
            }
        }

        // --- Summary: giorno / idle / settimana / mese ---
        GridLayout {
            Layout.fillWidth: true; columns: 2; columnSpacing: 8; rowSpacing: 4
            Text { text: "Day  " + ST.formatDur(root.dayActiveMs); color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
            Text { text: "Idle  " + ST.formatDur(root.dayIdleMs); color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 13; horizontalAlignment: Text.AlignRight; Layout.fillWidth: true }
            Text { text: "Week  " + ST.formatDur(root.weekMs); color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.fillWidth: true }
            Text { text: "Month  " + ST.formatDur(root.monthMs); color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 12; horizontalAlignment: Text.AlignRight; Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.bg2 }

        // --- Смуга таймлайну: Timeline ---
        ColumnLayout {
            Layout.fillWidth: true; spacing: 2

            Item {
                id: timelineTrack
                Layout.fillWidth: true; Layout.preferredHeight: 34

                Rectangle { anchors.fill: parent; radius: 5; color: Theme.bg1 }

                Repeater {
                    model: root.sessionsModel
                    delegate: Rectangle {
                        required property var modelData
                        readonly property real winStart: ST.dayStartMs(root.dateStr) + root.zoomStartMs
                        readonly property real winLen: root.zoomLenMs
                        readonly property real frac0: Math.max(0, Math.min(1, (modelData.start_ms - winStart) / winLen))
                        readonly property real frac1: Math.max(0, Math.min(1, (modelData.end_ms - winStart) / winLen))
                        x: frac0 * timelineTrack.width
                        width: Math.max((frac1 - frac0) * timelineTrack.width, (frac1 > frac0) ? 2 : 0)
                        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.topMargin: 3; anchors.bottomMargin: 3
                        radius: 2
                        color: modelData.idle ? Theme.bg2 : root.appColor(modelData.app)
                        opacity: 0.85
                    }
                }

                MouseArea {
                    id: trackHoverMa
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    property real _pressX: 0
                    property real _pressStartMs: 0
                    property bool _dragging: false
                    onEntered: root.hoverAt(mouseX)
                    onPositionChanged: (mouse) => {
                        root.hoverAt(mouseX);
                        if (pressed && Math.abs(mouse.x - _pressX) > 4) _dragging = true;
                        if (_dragging) {
                            var dayLen = 86400000;
                            root.zoomStartMs = Math.max(0, Math.min(dayLen - root.zoomLenMs, _pressStartMs - (mouse.x - _pressX) / timelineTrack.width * root.zoomLenMs));
                        }
                    }
                    onPressed: (mouse) => { _pressX = mouse.x; _pressStartMs = root.zoomStartMs; _dragging = false; }
                    onReleased: (mouse) => { if (!_dragging) root.stripClickAt(mouse.x / timelineTrack.width); _dragging = false; }
                    onExited: root.hoverInfo = ""
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y === 0) return;
                        root.wheelZoom(wheel.x / timelineTrack.width, wheel.angleDelta.y > 0);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 0
                Repeater {
                    model: root.tickLabels()
                    delegate: Text {
                        required property var modelData; required property int index
                        text: modelData; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 9; Layout.fillWidth: true
                        horizontalAlignment: index === 0 ? Text.AlignLeft : (index === 4 ? Text.AlignRight : Text.AlignHCenter)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 4
                Text {
                    Layout.fillWidth: true
                    text: root.hoverInfo !== "" ? root.hoverInfo : (root.zoomed ? "Drag to move • Wheel to zoom • Click to center" : "Hover for details • Wheel to zoom • Drag to move")
                    color: root.hoverInfo !== "" ? Theme.fg1 : Theme.fgMuted
                    font.family: Theme.fontFamily; font.pixelSize: 10; elide: Text.ElideRight; opacity: 0.9
                }
                Text { visible: root.zoomed; text: root.zoomRangeText(); color: Theme.grvGreen; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.bg2 }

        // --- Stato: Caricamento / Errore ---
        Text { visible: root.loading && root.appsModel.length === 0; text: "Loading…"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 12 }
        Text { visible: root.errorText !== ""; text: root.errorText; color: Theme.grvRed; font.family: Theme.fontFamily; font.pixelSize: 12 }
        Text { visible: !root.loading && root.errorText === "" && root.appsModel.length === 0; text: "No data for this day."; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 12 }

        // --- Lista Applicazioni (Flickable + Repeater) ---
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: appCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            clip: true

            Column {
                id: appCol
                width: parent.width; spacing: 6

                Repeater {
                    model: root.appsModel
                    delegate: Column {
                        required property var modelData
                        width: appCol.width; spacing: 3
                        readonly property bool expanded: root.pageApp === modelData.app

                        Rectangle {
                            width: parent.width; height: 30; radius: 6
                            color: rowMa.containsMouse ? Qt.rgba(Theme.bg1.r,Theme.bg1.g,Theme.bg1.b,0.8)/*Theme.workspaceBgHover*/ : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4; spacing: 8
                                
                                Item {
                                    Layout.preferredWidth: 20; Layout.preferredHeight: 20; Layout.alignment: Qt.AlignVCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: String(modelData.app).substring(0, 1).toUpperCase()
                                        color: root.appColor(modelData.app)
                                        font.family: Theme.fontFamily; font.pixelSize: 13; font.bold: true
                                    }
                                }

                                Text { text: (expanded ? "▾ " : "▸ ") + modelData.app; color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 13; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: ST.formatDur(modelData.ms); color: Theme.fg1; font.family: Theme.fontFamily; font.pixelSize: 12 }
                                Text { text: modelData.pct.toFixed(1) + "%"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 52; horizontalAlignment: Text.AlignRight }
                            }

                            MouseArea { id: rowMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.refreshPages(modelData.app) }
                        }

                        Rectangle {
                            width: parent.width; height: 4; radius: 2; color: Theme.bg1
                            Rectangle { width: parent.width * Math.min(1, modelData.pct / 100); height: parent.height; radius: 2; color: root.appColor(modelData.app) }
                        }

                        Column {
                            width: parent.width; spacing: 2; visible: expanded
                            Repeater {
                                model: expanded ? root.pagesModel : []
                                delegate: RowLayout {
                                    required property var modelData
                                    width: appCol.width; spacing: 8
                                    Text { text: "  └ " + ST.cleanTitle(modelData.app); color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: ST.formatDur(modelData.ms); color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 11 }
                                    Text { text: modelData.pct.toFixed(1) + "%"; color: Theme.fgMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.preferredWidth: 52; horizontalAlignment: Text.AlignRight }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
