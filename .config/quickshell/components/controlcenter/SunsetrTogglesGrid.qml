import qs
import "../commons"
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

/*!
    \qmltype SunsetrTogglesGrid
    \inherits GridLayout
    \inqmlmodule components.controlcenter
    \brief a 2x2 grid selector managing screen color temperature and blue light filters via sunsetr

    SunsetrTogglesGrid presents a preset picker for screen color temperature and gamma profiles dispatches profile switch commands asynchronously to \c sunsetr through the \c Hyprland IPC dispatcher

    Available Presets:
    \list
        \li \b {Day/Night} (\c {sunsetr p default}): automated sunrise/sunset temperature cycle
        \li \b {Gaming} (\c {sunsetr p gaming}): neutral, high-contrast profile tailored for color accuracy
        \li \b {Study} (\c {sunsetr p study}): warm, low-blue-light profile designed for reading and evening productivity
        \li \b {Off} (\c {sunsetr p static}): disables dynamic adjustments, enforcing a static neutral gamma
    \endlist

    example usage:
    \code
    import "../components/controlcenter"

    ColumnLayout {
        SunsetrTogglesGrid {
            Layout.fillWidth: true
        }
    }
    \endcode
*/

GridLayout {
    // TODO doesnt read status on popup opening
    id: btnRoot

    columns: 2
    columnSpacing: 8
    rowSpacing: 8
    // implicitHeight: content.implicitHeight
    Layout.fillWidth: true

    /*! \internal enforces that only one preset can be selected at a time. */
    ButtonGroup {
        id: modeGroup
    } 

    StyledRadio {
        id: defaultP

        Layout.fillWidth: true
        text: "󰹑 Day/Night"
        checked: true // default mode
        ButtonGroup.group: modeGroup
        onClicked: Hyprland.dispatch("hl.dsp.exec_cmd('sunsetr p default')")
    }

    StyledRadio {
        id: gaming

        ButtonGroup.group: modeGroup
        Layout.fillWidth: true
        text: "󱎓 Gaming"
        onClicked: {
            Hyprland.dispatch("hl.dsp.exec_cmd('sunsetr p gaming')");
        }
    }

    StyledRadio {
        id: study

        ButtonGroup.group: modeGroup
        Layout.fillWidth: true
        text: " Study"
        onClicked: {
            Hyprland.dispatch("hl.dsp.exec_cmd('sunsetr p study')");
        }
    }

    StyledRadio {
        id: offMode

        Layout.fillWidth: true
         text: "󰌵 Off"
        ButtonGroup.group: modeGroup
        onClicked: Hyprland.dispatch("hl.dsp.exec_cmd('sunsetr p static')")
    }
    
}
