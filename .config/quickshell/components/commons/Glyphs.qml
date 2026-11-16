
pragma Singleton
import QtQuick
import Quickshell

/*!
    \qmltype Glyphs
    \inherits Singleton
    \inqmlmodule components.commons
    \brief central registry and single source of truth for Nerd Font icon glyphs
    constructing glyphs programmatically with \c String.fromCodePoint ensures readability and allows icon swaps or corrections to be handled in a single location

    \note You must always specify \c {font.family: Glyphs.fontFamily} on any \c Text element displaying these glyphs to guarantee font fallback and glyph rendering

    Example usage:
    \code
    import QtQuick
    import "path/to/commons"

    Text {
        font.family: Glyphs.fontFamily
        font.pixelSize: 16
        text: Glyphs.wifi(NetworkService.sigStrength)
        color: Theme.fg0
    }
    \endcode
*/

Singleton {
    id: root

    /*!
        \qmlproperty string Glyphs::fontFamily
        the target font family required to render these symbol codepoints
        defaults to \c {"Symbols Nerd Font"}
    */

    readonly property string fontFamily: "Symbols Nerd Font"

    readonly property string refresh: cp(0xF0450)
    readonly property string close: cp(0xF0156)
    readonly property string lock: cp(0xF033E)
    readonly property string ethernet: cp(0xF0200)
    readonly property string wifiOff: cp(0xF092D)
    // wifi-strength-outline, -1, -2, -3, -4
    readonly property var wifiLevels: [cp(0xF092F), cp(0xF091F), cp(0xF0922), cp(0xF0925), cp(0xF0928)]
    readonly property string wifiFull: wifiLevels[4]

    /*!
        \qmlmethod string Glyphs::cp(int codepoint)
        \internal 
        converts codepoint integer to UTF-16 character
    */
    function cp(codepoint) {
        return String.fromCodePoint(codepoint);
    }

    
    /*!
        \qmlmethod string Glyphs::wifi(int strength)
        translates a percentage-based signal strength (\c {0..100}) into the corresponding stepped glyph from \l wifiLevels.

        Thresholds:
        \list
            \li \c {>= 75%}: Level 4 (full signal)
            \li \c {>= 50%}: Level 3
            \li \c {>= 25%}: Level 2
            \li \c {> 0%}:   Level 1
            \li \c {0%}:     Level 0 (outline / no signal)
        \endlist
    */
    function wifi(strength) {
        const s = strength || 0;
        const level = s >= 75 ? 4 : s >= 50 ? 3 : s >= 25 ? 2 : s > 0 ? 1 : 0;
        return wifiLevels[level];
    }
}
