import QtQuick
import Quickshell

/*!
    \qmltype GlyphIcon
    \inherits Item
    \inqmlmodule components.commons
    \brief versatile Nerd Font icon component with optional hover, click, scroll, tooltip, and command execution
    GlyphIcon unifies static icons, indicator icons, and icon buttons into a single lightweight component. if interactive features (clicks, hover, tooltips) are not used, it behaves as a simple visual glyph without unnecessary overhead

    Example usages:
    \code
    // static icon:
    GlyphIcon { glyph: ""; color: Theme.fgMuted }

    // action button with tooltip:
    GlyphIcon {
        glyph: Glyphs.close
        tooltipText: "Close Panel"
        onClicked: root.close()
    }

    // system indicator with launch command:
    GlyphIcon {
        glyph: "󰕾"
        command: ["pavucontrol"]
        onRightClicked: AudioService.toggleMute()
    }
    \endcode
*/

Item {
    id: root

    readonly property var targetScreen: Window.window ? Window.window.screen : (parent && parent.targetScreen ? parent.targetScreen : null)

    // ---- visual properties ----

    /*! \qmlproperty string GlyphIcon::glyph
        the symbol or codepoint character to render */
    required property string glyph

    /*! \qmlproperty color GlyphIcon::color
        resting foreground color of the glyph
        defaults to Theme.fg0. */
    property color color: (typeof Theme !== "undefined" && Theme.fg0) ? Theme.fg0 : "#ebdbb2"

    /*! \qmlproperty color GlyphIcon::hoverColor
        foreground color on hover
        defaults to root.color if not customized */
    property color hoverColor: (typeof Theme !== "undefined" && Theme.fg1) ? Theme.fg1 : root.color

    /*! \qmlproperty int GlyphIcon::pixelSize
        font size in pixels
        defaults to \c {14} */
    property int pixelSize: 14

    /*! \qmlproperty string GlyphIcon::fontFamily
        target Nerd Font family
        defaults to Glyphs.fontFamily */
    property string fontFamily: Glyphs.fontFamily

    // ---- interaction and behaviour ----

    /*! \qmlproperty bool GlyphIcon::clickable
        whether the icon responds to pointer interaction and displays a hand cursor */
    property bool clickable: true

    /*! \qmlproperty string GlyphIcon::tooltipText
        optional tooltip description
        if non-empty, displays CustomTooltip on hover */
    property string tooltipText: ""

    /*! \qmlproperty var GlyphIcon::command
        optional command (array or string) to execute detached via quickshell on primary click */
    property var command: []

    /*! \qmlproperty int GlyphIcon::paddingHorizontal
        horizontal padding added to the implicit width
        defaults to 4. */
    property int paddingHorizontal: 4

    /*! \qmlproperty int GlyphIcon::paddingVertical
        vertical padding added to the implicit height
        defaults to 2 */
    property int paddingVertical: 2

    // signals

    signal clicked() //var mouse
    signal rightClicked()
    signal middleClicked()
    signal wheelScrolled(int delta)

    // geometry

    implicitWidth: label.implicitWidth + (paddingHorizontal * 2)
    implicitHeight: label.implicitHeight + (paddingVertical * 2)

    Text {
        id: label
        anchors.centerIn: parent
        text: root.glyph
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        color: (root.clickable && mouseArea.containsMouse) ? root.hoverColor : root.color

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                root.clicked();

                // replaces heavy Quickshell.Io.Process
                if (Array.isArray(root.command) && root.command.length > 0) {
                    Quickshell.execDetached(root.command);
                } else if (typeof root.command === "string" && root.command.length > 0) {
                    Quickshell.execDetached(["sh", "-c", root.command]);
                }
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else if (mouse.button === Qt.MiddleButton) {
                root.middleClicked();
            }
        }

        onWheel: (wheel) => root.wheelScrolled(wheel.angleDelta.y)
    }

    // displays tooltip only if tooltipText is explicitly provided
    CustomTooltip {
        anchorItem: root
        show: mouseArea.containsMouse && root.tooltipText.length > 0
        text: root.tooltipText
    }
}