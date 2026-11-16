// ============================================================
// quickshell/popups/SelfTrackPopup.qml just GUI view
// ============================================================
// inspired by https://github.com/TripShuti/SELFtrack

import qs
import qs.services
import "../components/commons"
import "../scripts/SelfTrack.js" as ST
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

/*!
    \qmltype SelfTrackPopup
    \inherits BasePopup
    \inqmlmodule popups
    \brief interactive time tracking and application activity analytics popup

    \note this file is a mess
*/

BasePopup {
    id: root

    // view logic: zoom and hover
    // FIXME colored bands are square but the container bar is slightly rounded..
    property real zoomStartMs: 0
    property real zoomLenMs: 8.64e+07
    readonly property bool zoomed: root.zoomLenMs < 8.64e+07
    property string hoverInfo: ""
    readonly property var appColors: [Theme.grvGreen, Theme.grvBlue, Theme.grvYellow, Theme.grvPurple, Theme.grvOrange, Theme.grvAqua]

    function appColor(app) {
        return root.appColors[ST.appColorIndex(app, root.appColors.length)] || Theme.grvGreen;
    }

    function zoomReset() {
        root.zoomStartMs = 0;
        root.zoomLenMs = 8.64e+07;
    }

    function wheelZoom(frac, up) {
        const dayLen = 8.64e+07;
        const minLen = 60000;
        if (up && root.zoomLenMs <= minLen)
            return ;

        if (!up && root.zoomLenMs >= dayLen)
            return ;

        const newLen = Math.max(minLen, Math.min(dayLen, root.zoomLenMs * (up ? 1 / 1.3 : 1.3)));
        const tCursor = root.zoomStartMs + frac * root.zoomLenMs;
        root.zoomStartMs = Math.max(0, Math.min(dayLen - newLen, tCursor - frac * newLen));
        root.zoomLenMs = newLen;
        if (newLen >= dayLen)
            root.zoomReset();

    }

    function stripClickAt(frac) {
        const dayLen = 8.64e+07;
        if (root.zoomLenMs >= dayLen) {
            const h = Math.max(0, Math.min(23, Math.floor(frac * 24)));
            root.zoomStartMs = h * 3.6e+06;
            root.zoomLenMs = 3.6e+06;
        } else {
            const rel = root.zoomStartMs + frac * root.zoomLenMs;
            root.zoomStartMs = Math.max(0, Math.min(dayLen - root.zoomLenMs, rel - root.zoomLenMs / 2));
        }
    }

    function hoverAt(x) {
        const frac = Math.max(0, Math.min(1, x / timelineTrack.width));
        const base = ST.dayStartMs(SelfTrackService.dateStr);
        const t = base + root.zoomStartMs + frac * root.zoomLenMs;
        let best = null;
        let count = 0;
        const sessions = SelfTrackService.sessionsModel;
        for (let i = 0; i < sessions.length; i++) {
            const s = sessions[i];
            if (s.start_ms <= t && t < s.end_ms) {
                count++;
                if (!best || (s.end_ms - s.start_ms) < (best.end_ms - best.start_ms))
                    best = s;

            }
        }
        if (!best) {
            root.hoverInfo = ST.formatClock(t) + "  — no data —";
            return ;
        }
        let txt = ST.formatClock(best.start_ms) + "–" + ST.formatClock(best.end_ms) + "  ";
        if (best.idle) {
            txt += "idle";
        } else {
            const title = ST.cleanTitle(best.title);
            txt += best.app + (title !== "" ? " • " + title : "");
        }
        if (count > 1)
            txt += "  (+" + (count - 1) + " overlapping)";

        root.hoverInfo = txt;
    }

    function tickLabels() {
        if (root.zoomLenMs >= 8.64e+07)
            return ["00", "06", "12", "18", "24"];

        const base = ST.dayStartMs(SelfTrackService.dateStr);
        const showSec = root.zoomLenMs <= 300000;
        const labels = [];
        for (let i = 0; i <= 4; i++) {
            const t = base + root.zoomStartMs + (root.zoomLenMs * i) / 4;
            labels.push(showSec ? ST.formatClockS(t) : ST.formatClock(t));
        }
        return labels;
    }

    function zoomRangeText() {
        const base = ST.dayStartMs(SelfTrackService.dateStr);
        return ST.formatClock(base + root.zoomStartMs) + "–" + ST.formatClock(base + root.zoomStartMs + root.zoomLenMs);
    }

    ipcTarget: "selftrack"
    panelWidth: 420
    panelHeight: 560
    glowColor: Theme.grvYellow

    onOpened: {
        root.hoverInfo = "";
        SelfTrackService.refresh();
    }

    onClosed: {
        if (SelfTrackService.dateStr !== SelfTrackService._todayStr())
            SelfTrackService.goToday();

    }

    // reset zoom when date change
    Connections {
        function onDateStrChanged() {
            root.zoomReset();
        }

        target: SelfTrackService
    }

    // ---- BasePopup body ----
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // ---- header and date nav bar ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Time Tracking"
                color: root.glowColor
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            
            Rectangle {
                implicitWidth: 24
                implicitHeight: 24
                radius: 4
                color: navPrevMa.containsMouse ? Theme.hover : Theme.bg2
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: Theme.fg1
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                }

                MouseArea {
                    id: navPrevMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SelfTrackService.shiftDate(-1)
                }

            }

            // current date
            Text {
                text: SelfTrackService.dateStr
                color: Theme.fg1
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SelfTrackService.goToday()
                }

            }

            // 
            Rectangle {
                implicitWidth: 24
                implicitHeight: 24
                radius: 4
                color: navNextMa.containsMouse ? Theme.hover : Theme.bg2

                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: Theme.fg1
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                }

                MouseArea {
                    id: navNextMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SelfTrackService.shiftDate(1)
                }

            }

            // animated refresh button
            Rectangle {
                implicitWidth: 24
                implicitHeight: 24
                radius: 4
                color: refreshMa.containsMouse ? Theme.hover : Theme.bg2

                Text {
                    anchors.centerIn: parent
                    text: "⟳"
                    color: Theme.gray
                    font.family: Theme.fontFamily
                    font.pixelSize: 13

                    RotationAnimator on rotation {
                        running: SelfTrackService.loading
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 800
                    }

                }

                MouseArea {
                    id: refreshMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SelfTrackService.refresh()
                }

            }

            GlyphButton {
                glyph: Glyphs.close
                color: Theme.fgMuted
                pixelSize: 15
                onClicked: root.isOpen = false
            }

        }

        // summary stats
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 4

            Text {
                text: "Day  " + ST.formatDur(SelfTrackService.dayActiveMs)
                color: Theme.fg1
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: "Idle  " + ST.formatDur(SelfTrackService.dayIdleMs)
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 13
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }

            Text {
                text: "Week  " + ST.formatDur(SelfTrackService.weekMs)
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            Text {
                text: "Month  " + ST.formatDur(SelfTrackService.monthMs)
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }

        }

        // separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: root.glowColor
            opacity: 0.35
        }

        // timeline bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Item {
                //TODO fix clipping of bands

                id: timelineTrack
                Layout.fillWidth: true
                Layout.preferredHeight: 46

                // background track
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Theme.bg1
                    border.color: Theme.bg3
                    border.width: 1
                }


                // bar container
                Item {
                    id: barsClipContainer

                    anchors.fill: parent
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4

                    Repeater {
                        model: SelfTrackService.sessionsModel

                        delegate: Rectangle {
                            required property var modelData
                            readonly property real winStart: ST.dayStartMs(SelfTrackService.dateStr) + root.zoomStartMs
                            readonly property real winLen: root.zoomLenMs
                            readonly property real frac0: Math.max(0, Math.min(1, (modelData.start_ms - winStart) / winLen))
                            readonly property real frac1: Math.max(0, Math.min(1, (modelData.end_ms - winStart) / winLen))

                            x: frac0 * timelineTrack.width
                            width: Math.max((frac1 - frac0) * timelineTrack.width, (frac1 > frac0) ? 2 : 0)
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 3
                            anchors.bottomMargin: 3
                            radius: 2
                            color: modelData.idle ? Theme.bg3 : root.appColor(modelData.app)
                            opacity: 0.85
                        }

                    }

                }

                //drag and zoom
                MouseArea {
                    id: trackHoverMa
                    property real _pressX: 0
                    property real _pressStartMs: 0
                    property bool _dragging: false

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onEntered: root.hoverAt(mouseX)
                    onPositionChanged: (mouse) => {
                        root.hoverAt(mouseX);
                        if (pressed && Math.abs(mouse.x - _pressX) > 4)
                            _dragging = true;

                        if (_dragging) {
                            const dayLen = 8.64e+07;
                            root.zoomStartMs = Math.max(0, Math.min(dayLen - root.zoomLenMs, _pressStartMs - ((mouse.x - _pressX) / timelineTrack.width) * root.zoomLenMs));
                        }
                    }
                    onPressed: (mouse) => {
                        _pressX = mouse.x;
                        _pressStartMs = root.zoomStartMs;
                        _dragging = false;
                    }
                    onReleased: (mouse) => {
                        if (!_dragging)
                            root.stripClickAt(mouse.x / timelineTrack.width);

                        _dragging = false;
                    }
                    onExited: root.hoverInfo = ""
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y === 0)
                            return ;

                        root.wheelZoom(wheel.x / timelineTrack.width, wheel.angleDelta.y > 0);
                 }
                }


            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: root.tickLabels()

                    delegate: Text {
                        required property var modelData
                        required property int index

                        text: modelData
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        Layout.fillWidth: true
                        horizontalAlignment: index === 0 ? Text.AlignLeft : (index === 4 ? Text.AlignRight : Text.AlignHCenter)
                    }

                }

            }

            // widget info
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: root.hoverInfo !== "" ? root.hoverInfo : (root.zoomed ? "Drag to move • Wheel to zoom • Click to center" : "Hover for details • Wheel to zoom • Drag to move")
                    color: root.hoverInfo !== "" ? Theme.fg1 : Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    opacity: 0.9
                }

                Text {
                    visible: root.zoomed
                    text: root.zoomRangeText()
                    color: root.glowColor
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }

            }

        }

        // separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: root.glowColor
            opacity: 0.35
        }

        // ---- widget statuses ----
        Text {
            visible: SelfTrackService.loading && SelfTrackService.appsModel.length === 0
            text: "Loading…"
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        Text {
            visible: SelfTrackService.errorText !== ""
            text: SelfTrackService.errorText
            color: Theme.grvRed
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        Text {
            visible: !SelfTrackService.loading && SelfTrackService.errorText === "" && SelfTrackService.appsModel.length === 0
            text: "No data for this day."
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        // ---- apps list ----
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

                width: parent.width
                spacing: 6

                Repeater {
                    model: SelfTrackService.appsModel

                    delegate: Column {
                        required property var modelData
                        readonly property bool expanded: SelfTrackService.pageApp === modelData.app

                        width: appCol.width
                        spacing: 3

                        Rectangle {
                            width: parent.width
                            height: 30
                            radius: 6
                            color: rowMa.containsMouse ? Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.8) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 8

                                Item {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    Layout.alignment: Qt.AlignVCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: String(modelData.app).substring(0, 1).toUpperCase()
                                        color: root.appColor(modelData.app)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                }

                                Text {
                                    text: (expanded ? "▾ " : "▸ ") + modelData.app
                                    color: Theme.fg1
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: ST.formatDur(modelData.ms)
                                    color: Theme.fg1
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: modelData.pct.toFixed(1) + "%"
                                    color: Theme.fgMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 52
                                    horizontalAlignment: Text.AlignRight
                                }

                            }

                            MouseArea {
                                id: rowMa

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SelfTrackService.refreshPages(modelData.app)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 4
                            radius: 2
                            color: Theme.bg1

                            Rectangle {
                                width: parent.width * Math.min(1, modelData.pct / 100)
                                height: parent.height
                                radius: 2
                                color: root.appColor(modelData.app)
                            }

                        }

                        Column {
                            width: parent.width
                            spacing: 2
                            visible: expanded

                            Repeater {
                                model: expanded ? SelfTrackService.pagesModel : []

                                delegate: RowLayout {
                                    required property var modelData

                                    width: appCol.width
                                    spacing: 8

                                    Text {
                                        text: "  └ " + ST.cleanTitle(modelData.app)
                                        color: Theme.fgMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: ST.formatDur(modelData.ms)
                                        color: Theme.fgMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        text: modelData.pct.toFixed(1) + "%"
                                        color: Theme.fgMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        Layout.preferredWidth: 52
                                        horizontalAlignment: Text.AlignRight
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
