import QtQml
import Quickshell
import "components/effects"
import "modules"
import "monitors"
import "osd"

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
                onOpenSelfTrackRequested: selftrackWindow.visible = !selftrackWindow.visible
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

    Instantiator {
        model: Quickshell.screens

        delegate: InstantiatorOSDs {
            required property var modelData

            screen: modelData
        }

    }

 PanelWindow {
        id: selftrackWindow

        // 1. Parte nascosto (si aprirà dal bottone)
        visible: false 
        // 2. FONDAMENTALE: Sfondo trasparente per far vedere l'ombra
        color: "transparent" 

        // 3. Aggiungiamo 28px di spazio extra per l'ombra (14 per lato)
        implicitWidth: 380 + 28
        implicitHeight: 520 + 28

        anchors {
            top: true
            left: true // o right: true, a seconda di dove hai il modulo nella topbar
        }

        margins {
            top: 10
            left: 200 // Aggiusta questi margini per allinearlo sotto il bottone
        }

        ExpandingGlowPanel {
            // 4. Invece di riempire la finestra, gli diamo la dimensione esatta e lo centriamo
            width: 380
            height: 520
            anchors.centerIn: parent 
            
            expanded: selftrackWindow.visible

            SelfTrackMonitor {
                anchors.fill: parent
                anchors.margins: 14 // Margine interno, come nel Control Center
                settings: Settings
            }
        }
    }
}
