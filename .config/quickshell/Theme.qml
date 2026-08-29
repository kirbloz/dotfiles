import QtQuick
pragma Singleton

QtObject {
    // Gruvbox Dark
    readonly property color bg0_hard: "#1d2021"
    readonly property color bg0: "#282828"
    readonly property color bg1: "#3c3836"
    readonly property color bg2: "#504945"
    readonly property color bg3: "#665c54"
    readonly property color bg4: "#7c6f64"
    readonly property color fg0: "#fbf1c7"
    readonly property color fg1: "#ebdbb2"
    readonly property color fg2: "#d5c4a1"
    readonly property color fg3: "#bdae93"
    readonly property color fg4: "#a89984"

    readonly property color fgMuted: "#a89984"
    readonly property color hover: "#427b58"

    readonly property color darkgray: "#171717"
    readonly property color gray: "#928374"
    readonly property color grvOrange: "#fe8019"
    readonly property color grvRed: "#fb4934"
    readonly property color grvGreen: "#b8bb26"
    readonly property color grvYellow: "#fabd2f"
    readonly property color grvBlue: "#83a598"
    readonly property color grvPurple: "#d3869b"
    readonly property color grvAqua: "#8ec07c"
    readonly property color grvRedDim: "#cc2412"
    readonly property color grvGreenDim: "#98971a"
    readonly property color grvyellowDim: "#d79921"
    readonly property color grvBlueDim: "#458588"
    readonly property color grvPurpleDim: "#b16286"
    readonly property color grvAquaDim: "#689d6a"
    readonly property color grvOrangeDim: "#d65d0e"


    readonly property color workspaceBgEmpty: "transparent"
    readonly property color workspaceBgActive: darkgray       // #171717 — pill, come .active/.visible nel CSS
    readonly property color workspaceBgFocused: darkgray      // stesso colore: il vecchio CSS non li distingueva
    readonly property color workspaceBgHover: "#b3fabd2f"     // grvYellow al 70% alpha (b3 = 0.7 * 255), come alpha(@workspacecolor, 0.7)

    readonly property color workspaceFgEmpty: fg1              // @textcolor1
    readonly property color workspaceFgActive: grvYellow       // @workspacecolor
    readonly property color workspaceFgFocused: grvYellow      // stesso, il CSS non li distingueva
    readonly property color workspaceFgHover: darkgray         // @workspacebackground1 (#171717), come nel :hover del CSS
    readonly property int workspaceRadius: 15
    readonly property int radius: 8
    readonly property string fontFamily: "Fira Sans Mono"
}
