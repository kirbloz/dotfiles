import qs
import "../core"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

/*! \qmltype Basepopup
    \inherits PanelWindow
    \brief re-usable element, uses CrtPanel to style itself
    */
PanelWindow {
    id: root

    property string ipcTarget: ""
    default property alias content: frame.content
    /*! \qmlproperty BasePopup::isOpen
        if true, popup is visible */
    property bool isOpen: false
    property bool needsExclusiveKeyboard: false
    property bool isWindowVisible: false
    /*! \qmlproperty Basepopup::panelWidth
        overridable width of container panel, has a fallback hardcoded size */
    property int panelWidth: (typeof Settings !== "undefined" && Settings.notifPanelWidth) ? Settings.notifPanelWidth : 360
    /*! \qmlproperty Basepopup::panelHeight
        overridable height of container panel, has a fallback hardcoded size */
    property int panelHeight: (typeof Settings !== "undefined" && Settings.notifPanelHeight) ? Settings.notifPanelHeight : 440
    property color glowColor: (typeof Theme !== "undefined" && Theme.grvYellow) ? Theme.grvYellow : "#fabd2f"
    /*! \qmlproperty BasePopup::glowPad
        small extra space around panel for correct displaying of CRT glow*/
    readonly property int glowPad: 24

    signal opened()
    //signal closed()

    // place window centered on centerX
    function placeAt(centerX) {
        const screenW = root.screen ? root.screen.width : 1920;
        const totalW = root.panelWidth + (root.glowPad*2);
        let targetX = centerX - (totalW / 2);
        targetX = Math.max(10, Math.min(targetX, screenW - totalW - 10));
        root.margins.left = targetX;
    }

    // open popup
    function toggleFrom(targetItem, globalPos) {
        if(isOpen) {
            isOpen = false;
            return;
        }

        if(targetItem && globalPos){
            placeAt(globalPos.x+targetItem.width/2);
        }

        isOpen=true;
    }

    // open popup using IPC
    function openAtDefault() {
        const screenW = root.screen ? root.screen.width : 1920;
        placeAt(screenW - root.width - 20);
        isOpen = true;
    }

    // window behaviour and styling
    color: "transparent"
    visible: isWindowVisible
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? (needsExclusiveKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand) : WlrKeyboardFocus.None
    implicitWidth: panelWidth + glowPad * 2
    implicitHeight: panelHeight + glowPad * 2

    // triggers open and close animation
    onIsOpenChanged: {
        if (isOpen) {
            root.isWindowVisible = true;
            closeTimer.stop();
            root.opened();
            Qt.callLater(frame.forceActiveFocus);
        } else {
            root.closed();
            closeTimer.restart();
        }
    }

    anchors {
        top: true
        left: true
    }

    margins {
        top: (typeof Settings !== "undefined" && Settings.notifPillHeight) ? (Settings.notifPillHeight + 6) : 40
    }

    // timer for closing animation
    Timer {
        id: closeTimer

        interval: 190
        onTriggered: root.isWindowVisible = false
    }

    CrtPanel {
        id: frame

        // position panel and centerX and leave space for glow
        anchors.centerIn: parent
        width: root.panelWidth
        height: root.panelHeight
        glowColor: root.glowColor
        focus: true
        Keys.onEscapePressed: (event) => {
            // if not intercepted by children first, closes popup
            root.isOpen = false;
        }
        opacity: root.isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }

        }

        transform: Translate {
            y: root.isOpen ? 0 : -10

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    IpcHandler {
        function toggle() {
            root.isOpen = !root.isOpen;
        }

        function open() {
            root.openAtDefault();
        }

        function close() {
            root.isOpen = false;
        }

        target: root.ipcTarget
        enabled: root.ipcTarget !== ""
    }

}
