import qs
import qs.services
import "../core"
import "../commons"
import QtQuick
import QtQuick.Layouts

/*!
    \qmltype NotificationPill
    \inherits WidgetBase
    \inqmlmodule components.bar
    \brief status bar pill displaying notification count, DND state, with hover-to-open drawer behavior

    NotificationPill displays current unread notifications count and DND status with high-contrast yellow-capsule styling

    click behaviour:
    \list
        \li \b {Left Click}: toggles the notification center popip
        \li \b {Right Click}: toggles Do Not Disturb (DND) via \l NotifsManager
        \li \b {Middle Click}: clears all notification history
    \endlist
*/

WidgetBase {
    id: root
    type: "notifications"

    // ---- state properties ----
    readonly property int notifCount: NotifsManager.count
    readonly property bool isPaused: NotifsManager.isPaused

    // ---- views and geometry ----
    color: Theme.grvYellow
    radius: height / 2
    implicitWidth: { root.notifCount < 1 ? layout.implicitWidth + 10 : layout.implicitWidth + 20 }
    severity: NotifsManager.isPaused ? "warning" : (NotifsManager.hasNotifications ? "active" : "normal")

    // override WidgetBase's MouseArea to specify a new hover dynamic
    interactive: false 
    onClicked: PopupService.toggle("notifications", root)
    onRightClicked: NotifsManager.toggleDnd()

    Timer {
        id: hoverOpenTimer
        interval: 120
        onTriggered: {
            if (PopupService.notifCenterPopup)
                PopupService.notifCenterPopup.open();
        }
    }

    Timer {
        id: hoverCloseTimer
        interval: 150
        onTriggered: {
            if (PopupService.notifCenterPopup)
                PopupService.notifCenterPopup.requestClose();
        }
    }

    // internal layout = glyph + count
    RowLayout {
        id: layout
        spacing: 6

        Text {
            leftPadding: { root.notifCount < 1 ?  6 : 0 }
            text: {
                if (root.isPaused)
                    return root.notifCount > 0 ? "󰂛" : "󰪑";
                return root.notifCount > 0 ? "󱅫" : "󰂜";
            }
            font.family: Glyphs.fontFamily
            font.pixelSize: 18
            color: "#171717"
        }

        Text {
            visible: root.notifCount > 0
            text: root.notifCount.toString()
            font.family: Theme.fontFamily
            font.pixelSize: 16
            font.bold: true
            color: "#171717"
        }

    }

    // ---- interaction area ----
    MouseArea {
        // FIXME this anchors.fill raises a warning (anchor on item managed by layout) but if removed entirely the hover-open logic breaks
        anchors.fill:parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            console.log(" [NotifPill] detected hover")
            hoverCloseTimer.stop();
            hoverOpenTimer.restart();
        }
        onExited: {
            console.log(" [NotifPill] stopped hovering")
            hoverOpenTimer.stop();
            hoverCloseTimer.restart();
        }
        onClicked: (mouse) => {
            console.log(" [NotifPill] detected click")
            if (mouse.button === Qt.LeftButton)
                PopupService.toggle("notifications");
            else if (mouse.button === Qt.RightButton)
                NotifsManager.toggleDnd();
            else if (mouse.button === Qt.MiddleButton)
                NotifsManager.clearHistory();
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }

    }

}
