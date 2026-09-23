import QtQuick
import Quickshell.Hyprland
import "../.."

Rectangle {
    id: root

    required property int wsId
    required property int index

    property var hyprWs: Hyprland.workspaces.values.find(w => w.id === wsId)

    property bool focused: !!(hyprWs && hyprWs.focused)
    property bool active: !!(hyprWs && hyprWs.active)
    property bool occupied: !!(hyprWs && hyprWs.toplevels.values.length > 0)
    property bool hovered: mouseArea.containsMouse

    // hover > focused > active > occupato > vuoto
    readonly property string variant: hovered ? "hover"
                                     : focused ? "focused"
                                     : active  ? "active"
                                     : occupied ? "occupied"
                                     : "empty"

    readonly property var colors: ({
        hover:    { bg: Theme.workspaceBgHover,   fg: Theme.workspaceFgHover },
        focused:  { bg: Theme.workspaceBgFocused, fg: occupied ? Theme.workspaceFgFocused : Theme.workspaceFgEmpty },
        active:   { bg: Theme.workspaceBgActive,  fg: occupied ? Theme.workspaceFgActive  : Theme.workspaceFgEmpty },
        occupied: { bg: Theme.workspaceBgEmpty,   fg: Theme.workspaceFgActive },
        empty:    { bg: Theme.workspaceBgEmpty,   fg: Theme.workspaceFgEmpty }
    })

    width: (focused || active) ? 40 : 25
    height: 25
    radius: Theme.workspaceRadius
    color: colors[variant].bg

    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: ["一","二","三","四","五","六","七","八","九","十"][root.wsId - 1]
        font.pixelSize: 15
        font.bold: true
        color: root.colors[root.variant].fg
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        //dispatch hl.dsp.focus({workspace = 1})
        //onClicked: Hyprland.dispatch("workspace " + root.wsId)
        onClicked: Hyprland.dispatch("hl.dsp.focus({workspace = " + root.wsId + "})")
    }
}