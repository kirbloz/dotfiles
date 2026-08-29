import QtQml
import Quickshell
import "modules"

ShellRoot {

    // one monitor = one bar
    Scope {
        Instantiator {
            model: Quickshell.screens

            delegate: TopBar {
                id: bar

                //  screen: modelData
                visible: true
                onOpenNotifCenterRequested: notifCenter.visible = !notifCenter.visible
                onOpenControlCenterRequested: controlCenter.visible = !controlCenter.visible
            }
        }
    }

    ControlCenter {
        id: controlCenter

        visible: false
    }

    NotificationsCenter {
        id: notifCenter
    }

    SystemDashboard {
        id: dashboard
    }
}
