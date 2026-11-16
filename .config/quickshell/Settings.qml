pragma Singleton
import QtQuick

QtObject {

    // locale for time and date: "" = system locale, or e.g. "it_IT"
    readonly property string locale: ""
    readonly property string timeFormat: "HH:mm"
    readonly property string dateFormat: "ddd dd MMM"

    // --- def apps ---
    readonly property string terminal: "kitty"
    readonly property string browser: "firefox"
    readonly property string fileManager: "nemo"
    readonly property string editor: "vim"

    // ---  SelfTrack ---
    // FIXME idk what i did here
    readonly property string selftrackScriptPath: "/home/" + sysEnvUser + "/.config/quickshell/scripts/selftrack.py"
    readonly property int selftrackInterval: 2000 
    readonly property bool selftrackEnabled: true
    readonly property string sysEnvUser: "YOU" 
    
    // --- screen recorder ---
    property string recordDir: ""
    property int recordFps: 60
    property string recordQuality: "high"
    property bool recordCursor: true
    property bool recordMic: false
    property bool recordDesktop: true
    property int recordCountdown: 3
    property real recordClearedBefore: 0

    // --- notification center ---
    readonly property int notifPillHeight: 36
    readonly property int notifPanelWidth: 340
    readonly property int notifPanelHeight: 500
    readonly property int notifPollInterval: 2000
    readonly property int notifOpenAnimDuration: 350
    readonly property int notifCloseAnimDuration: 200
    readonly property int notifHoverOpenDelay: 120
    readonly property int notifHoverCloseDelay: 250

    readonly property int wifiPanelCloseAnim: 100

    // --- calendar ---
    readonly property int calendarPopupWidth: 400
    readonly property int calendarPopupHeight: 360

    // --- temperature ---
    readonly property int criticalTempThreshold: 75
    readonly property int warningTempThreshold: 65

    // --- volume ---
    readonly property int volumeAdjustStep: 5

    // --- settings gui ---
    readonly property int settingsPopupAnimDuration: 250
    readonly property int settingsPopupOpacityAnimDuration: 220
    readonly property string sysinfoScriptPath: "/.config/neperozlinuz/scripts/sysinfo.sh"
    readonly property string themeConfPath: "/.config/neperozlinuz/theming/theming.conf"
    readonly property string themeScriptPath: "/.config/neperozlinuz/theming/setup.sh"

    readonly property string batteryHw: "/sys/class/power_supply/BAT1"
    
    readonly property string weatherScriptPath: "/.config/quickshell/scripts/get-weather"
    }