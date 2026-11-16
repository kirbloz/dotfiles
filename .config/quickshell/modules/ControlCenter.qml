import qs
import qs.services
import "../components"
import "../components/commons"
import "../components/controlcenter"
import "../components/effects"
import "../notifications"

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io 

/*!
    \qmltype ControlCenter
    \inherits BasePopup
    \inqmlmodule modules
    \brief popup with widgets to control various aspects of the system such as volume, backlight, quick toggles (mute, deafen etc) and blue light reduction
*/

BasePopup {
    id: root

    ipcTarget: "controlcenter"
    panelWidth: 400
    panelHeight: mainLayout.implicitHeight + 28

    // ---- main body ----
    ColumnLayout {
        id: mainLayout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 14
        spacing: 10

        // title header
        Header {
            onCloseRequested: {
                root.isOpen = false;
            }
            title: "Control Center"
        }

        QuickTogglesGrid {
            Layout.fillWidth: true
        }

        //separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.grvYellow
            opacity: 0.3
        }

        BacklightWidget {
            Layout.fillWidth: true
        }

        VolumeWidget {
            Layout.fillWidth: true
        }

        // separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.grvYellow
            opacity: 0.3
        }

        // blue light reduction controller, uses sunsetr 
        SunsetrTogglesGrid {
            Layout.fillWidth: true

        }

    }

}
