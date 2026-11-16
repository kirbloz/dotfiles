
import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
/*!
    \qmltype CornerFlyout
    \inherits PanelWindow
    \inqmlmodule popups
    \brief bottom-right corner drawer with concave fillets and hover-slide expansion

    CornerFlyout is an unobtrusive desktop dock pinned to the bottom-right corner of the screen; when collapsed, it shrinks its input mask to a tiny edge notch to allow clicks to pass through to underlying desktop windows; upon hovering over the notch, it expands diagonally into a pill drawer holding quick-access utility shortcuts

    example usage:
    \code
    import "popups"

    Variants {
        model: Quickshell.screens
        CornerFlyout {
            screen: modelData
            onOpenSettingsRequested: settingsWindow.open()
            onOpenDashboardRequested: dashboardPopup.toggle()
        }
    }
    \endcode
*/

PanelWindow {
    id: flyoutRoot

    /*! \qmlproperty bool CornerFlyout::expanded
        indicates whether the corner drawer is currently expanded */
    property bool expanded: false

    /*! \qmlproperty real CornerFlyout::progress
        transition progress between \c {0.0} (collapsed) and \c {1.0} (fully open) */
    property real progress: expanded ? 1 : 0

    // ---- geometry ----
    /*! \internal concave fillet radius where the drawer transitions into the screen edge */
    readonly property int filletRadius: 20

    /*! \internal convex corner radius for the inner top-left corner of the drawer */
    readonly property int cornerRadius: 20

    /*! \internal dynamic panel width calculated based on the content row + horizontal padding */
    readonly property int panelWidth: contentLayout.implicitWidth + 32

    /*! \internal height of the active drawer body */
    readonly property int panelHeight: 60

    /*! \internal hitbox width when collapsed in the screen corner */
    readonly property int hotspotWidth: 16

    /*! \internal hitbox height when collapsed (matches the edge indicator height + margin) */
    readonly property int hotspotHeight: 40


    // ---- signals ----
    signal openSettingsRequested()
    signal openDashboardRequested()

    // ---- window ----
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // fixed size: the drawer slides inside the window instead of resizing it
    implicitWidth: panelWidth + filletRadius
    implicitHeight: panelHeight + filletRadius

    anchors {
        bottom: true
        right: true
    }

    // only the visible drawer (or the corner hotspot) receives input
    mask: Region {
        item: inputArea
    }

    Behavior on progress {
        NumberAnimation {
            duration: 320
            easing.type: Easing.BezierSpline
            // Material 3 "emphasized decelerate" curve
            easing.bezierCurve: [0.05, 0.7, 0.1, 1, 1, 1]
        }
    }

    // ---- hitbox & hover logic ----

    // grace period after pointer leaves area
    Timer {
        id: leaveTimer

        interval: 400
        onTriggered: flyoutRoot.expanded = false
    }

    /*! \internal dynamic input hitbox driving the Wayland input mask */
    
    Item {
        id: inputArea
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: flyoutRoot.expanded ? parent.width : flyoutRoot.hotspotWidth
        height: flyoutRoot.expanded ? parent.height : flyoutRoot.hotspotHeight
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                leaveTimer.stop();
                flyoutRoot.expanded = true;
            } else {
                leaveTimer.restart();
            }
        }
    }

    // small hint on the screen edge while collapsed
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 4
        height: 28
        radius: 2
        color: Theme.grvYellow
        opacity: (1 - flyoutRoot.progress) * 0.6
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    // ---- drawer ---------------
    /*! /internal uses QtQuick \c Shape and bezier path arcs to render organic fillets where the drawer connects to the screen boundaries */
    Item {
        id: drawer
        anchors.fill: parent
        opacity: flyoutRoot.progress > 0.01 ? 1 : 0

        transform: Translate {
            x: (1 - flyoutRoot.progress) * drawer.width
            y: (1 - flyoutRoot.progress) * drawer.height
        }

        // panel + concave fillets as one shape
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: panelPath

                readonly property real w: drawer.width
                readonly property real h: drawer.height
                readonly property real r: flyoutRoot.filletRadius
                readonly property real c: flyoutRoot.cornerRadius

                fillColor: Theme.bg0
                strokeColor: "transparent" // no border

                // start: bottom edge, left end of the bottom concave fillet
                startX: 0
                startY: panelPath.h

                // concave fillet up to the panel's left side
                PathArc {
                    x: panelPath.r
                    y: panelPath.h - panelPath.r
                    radiusX: panelPath.r
                    radiusY: panelPath.r
                    direction: PathArc.Counterclockwise
                }

                // panel left side
                PathLine {
                    x: panelPath.r
                    y: panelPath.r + panelPath.c
                }

                // convex top-left corner
                PathArc {
                    x: panelPath.r + panelPath.c
                    y: panelPath.r
                    radiusX: panelPath.c
                    radiusY: panelPath.c
                    direction: PathArc.Clockwise
                }

                // panel top side
                PathLine {
                    x: panelPath.w - panelPath.r
                    y: panelPath.r
                }

                // concave fillet up to the right screen edge
                PathArc {
                    x: panelPath.w
                    y: 0
                    radiusX: panelPath.r
                    radiusY: panelPath.r
                    direction: PathArc.Counterclockwise
                }

                PathLine {
                    x: panelPath.w
                    y: panelPath.h
                }

                PathLine {
                    x: 0
                    y: panelPath.h
                }
            }
        }

        // buttons container area
        Item {
            x: flyoutRoot.filletRadius
            y: flyoutRoot.filletRadius
            width: flyoutRoot.panelWidth
            height: flyoutRoot.panelHeight

            RowLayout {
                id: contentLayout
                anchors.centerIn: parent
                spacing: 8

                DrawerButton {
                    icon: "󰔎"
                    label: "Settings"
                    accent: Theme.grvYellow
                    onClicked: {
                        flyoutRoot.openSettingsRequested();
                        flyoutRoot.expanded = false;
                    }
                }

                DrawerButton {
                    icon: "󰒋"
                    label: ""
                    accent: Theme.grvAqua
                    onClicked: {
                        flyoutRoot.openDashboardRequested();
                        flyoutRoot.expanded = false;
                    }
                }
            }
        }
    }
}
