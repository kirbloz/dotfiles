pragma Singleton
import QtQuick

QtObject {
    // --- def apps ---
    readonly property string terminal: "kitty"
    readonly property string browser: "firefox"
    readonly property string fileManager: "nemo"
    readonly property string editor: "vim"

    // ---  SelfTrack ---
    readonly property string selftrackScriptPath: "/home/" + sysEnvUser + "/.config/quickshell/scripts/selftrack.py"
    readonly property int selftrackInterval: 2000 
    readonly property bool selftrackEnabled: true
    readonly property string sysEnvUser: "giovanni" 
    
    // --- screen recorder ---
    property string recordDir: ""
    property int recordFps: 60
    property string recordQuality: "high"
    property bool recordCursor: true
    property bool recordMic: false
    property bool recordDesktop: true
    property int recordCountdown: 3
    property real recordClearedBefore: 0

// --- Notification Center ---
    readonly property int notifPillHeight: 36
    readonly property int notifPanelWidth: 340
    readonly property int notifPanelHeight: 500
    readonly property int notifPollInterval: 2000
    readonly property int notifOpenAnimDuration: 350
    readonly property int notifCloseAnimDuration: 200
    readonly property int notifHoverOpenDelay: 120
    readonly property int notifHoverCloseDelay: 250

    }