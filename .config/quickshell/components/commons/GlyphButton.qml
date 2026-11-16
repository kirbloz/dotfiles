import qs
import QtQuick

/*! \qmltype GlyphButton
    \inqmlmodule components.commons
    \inherits Item
    \brief lightweight stateless icon button. displays a glyph and emits click events
    \c GlyphButton wraps a single char or symbol inside an interactive area; it handles hover states and cursor shape changes

    example usage:
    \code
    GlyphButton {
        glyph: Glyphs.close
        color: Theme.fgMuted
        hoverColor: Theme.grvRed
        onClicked: root.close()
    }
    \endcode 
    */

Item {
    id: root

    /*! \qmlproperty string GlyphButton::glyph
        the char, symbol, or codepoint to display */
    property string glyph: ""
    /*! \qmlproperty color GlyphButton::color
        resting (non-hovered) foreground color of the glyph
        defaults to \c {Theme.fg1}
    */
    property color color: Theme.fg1
    /*! \qmlproperty color GlyphButton::color
        hovered foreground color of the glyph
        defaults to \c {Theme.fg0} 
    */
    property color hoverColor: Theme.fg0
    /*! \qmlproperty int GlyphButton::pixelSize
        font pixel size used to render the glyph
        defaults to \c {14}
        */
    property int pixelSize: 14

    /*!
        \qmlsignal GlyphButton::clicked()
        emitted whenever the button is clicked with the primary (left) mouse button
    */
    signal clicked()

    implicitWidth: label.implicitWidth + 8
    implicitHeight: label.implicitHeight + 4

    Text {
        id: label

        anchors.centerIn: parent
        text: root.glyph
        color: area.containsMouse ? root.hoverColor : root.color
        font.family: Glyphs.fontFamily
        font.pixelSize: root.pixelSize
        
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
