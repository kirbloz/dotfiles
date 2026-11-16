import QtQml
import Quickshell
import "components/core"
import "modules"
import "osd"
import "popups"
import qs.services

ShellRoot {

    ControlCenter {
        id: globalControlCenterPopup
        Component.onCompleted: PopupService.register("controlCenter", this)
    }

    NotificationsCenter {
        id: notifCenter
        Component.onCompleted: PopupService.register("notifications", this)
    
    }

    ModernDashboard {
        id: globalDashboardPopup
        Component.onCompleted: PopupService.register("dashboard", this)
    }

    NetworkPopup {
        id: globalNetPopup
        Component.onCompleted: PopupService.register("network", this)
    }

    SelfTrackPopup {
        id: globalSelfTrackPopup
        Component.onCompleted: PopupService.register("selfTrack", this)
    }

    CalendarPopup {
        id: globalCalendarPopup
        Component.onCompleted: PopupService.register("calendar", this)
    }

    SettingsWindow {
        id: globalSettingsWindow
    }

    // one monitor = one bar
    Scope {
        Instantiator {
            model: Quickshell.screens

            delegate: TopBar {
                id: bar
                visible: true
            }

        }

        Instantiator {
            model: Quickshell.screens

            delegate: InstantiatorOSDs {
                required property var modelData
                screen: modelData
            }

        }

        Variants {
            model: Quickshell.screens

            CornerFlyout {
                required property var modelData
                screen: modelData

                onOpenSettingsRequested: {
                    globalSettingsWindow.open();
                }
                onOpenDashboardRequested: {if (typeof globalDashboardPopup !== "undefined")
                        globalDashboardPopup.isOpen = !globalDashboardPopup.isOpen;
                }
            }
        }

    }

    

}
