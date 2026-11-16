import qs
import QtQuick
import QtQuick.Controls

/*!
    \qmltype StyledRadio
    \inherits RadioButton
    \inqmlmodule components.commons
    \brief custom-styled Gruvbox radio button with capsule background and circular indicator

    StyledRadio customizes the QtQuick Controls \c RadioButton to match the shell's Gruvbox & Retro-CRT visual language; grouped inside a \c ButtonGroup to manage mutually exclusive settings (such as Power Profiles, Performance modes, or audio sinks) but not limited to that

    key features:
    \list
        \li \b {Styling}: adapts the entire control into an interactive pill, shifting background color to \c {Theme.grvYellow} and text to \c {Theme.bg0} when checked
        \li \b {Dynamic Bullet}: renders a custom 14px circular indicator bullet with distinct resting, hovered, and checked states
    \endlist

    Example usage:
    \code
    import QtQuick.Controls
    import "../components/commons"

    ButtonGroup { id: profileGroup }

    RowLayout {
        StyledRadio {
            text: "Power Saver"
            ButtonGroup.group: profileGroup
        }
        StyledRadio {
            text: "Balanced"
            checked: true
            ButtonGroup.group: profileGroup
        }
        StyledRadio {
            text: "Performance"
            ButtonGroup.group: profileGroup
        }
    }
    \endcode
*/



RadioButton {
    // TODO this is just placeholder code - i needed this to work. as of now it is incredibly ugly (and doesnt really work, sigh)  
    id: control

    // ---- geometry and padding ----
    implicitHeight: 34
    implicitWidth: indicator.width + control.indicator.implicitWidth + 24

    spacing: 8
    padding: 6
    leftPadding: 10; rightPadding: 10;
    

    // ---- background: QuickButton-like style ----
    background: Rectangle {
        radius: Theme.radius
        color: "transparent" //control.checked ? Theme.grvYellow : (control.hovered ? Theme.grvOrangeDim : "transparent")
        border.color: control.checked ? Theme.grvYellow : Theme.bg3
        border.width: 0

        opacity: 0.6

        Behavior on color {
            ColorAnimation { duration: 120}
        }
        Behavior on border.color {
            ColorAnimation { duration: 120}
        }
    }

    // TODO align these two

    indicator: Rectangle {
        x: control.leftPadding
        y: Math.round((control.height-height)/2)

        width: 14
        height: 14
        radius: 7
        
        //anchors.left: parent.left
        //anchors.leftMargin: 8
        //anchors.verticalCenter: parent.verticalCenter
        
        // outer ring
        border.width: 2
        border.color: control.checked ? Theme.grvYellow : Theme.fgMuted
        color: "transparent"

        // inner dot (visible when checked)
        Rectangle {
            anchors.centerIn: parent
            width: 6; height: 6; radius: 3;
            visible: control.checked
            color: Theme.grvYellow
        }

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

    }

    // text label
    contentItem: Text {
        text: control.text

        leftPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter
        
        color: control.checked ? Theme.fg0 : (control.hovered ? Theme.fg1 : Theme.fgMuted)
        
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.bold: control.checked
        elide: Text.ElideRight
    
        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

  



}
