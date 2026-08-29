import QtQuick
import Quickshell
pragma Singleton


Singleton {
    id: flags

    // Screen Recorder
    property string recordDir: ""
    property int recordFps: 60
    property string recordQuality: "high"
    property bool recordCursor: true
    property bool recordMic: false
    property bool recordDesktop: true
    property int recordCountdown: 3
    property real recordClearedBefore: 0

    // to be implemented
    property bool dnd: false
    property bool gameMode: false
    property bool keepAwake: false
    property real uiScale: 1.0
    property real topGap: 1.0
    property real appGap: 1.0
}