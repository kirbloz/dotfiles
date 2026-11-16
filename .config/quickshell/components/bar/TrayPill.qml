import qs
import "../core"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

/*!
    \qmltype TrayPill
    \inherits WidgetBase
    \inqmlmodule components.bar
    \brief system tray capsule with automatic collapsing

    TrayPill renders active background application tray icons provided by Quickshell's native \c SystemTray service

    key features:
    \list
        \li \b {Auto-Collapsing}: when no tray items are present (\c {hasContent == false}), the parent \l WidgetBase collapses its width and padding to zero
        \li \b {Icon Resolution}: automatically handles both standard desktop theme icons (resolved via \c Quickshell.iconPath) and direct DBus pixmap image streams (using \c image:// or custom query paths)
        \li \b {Full SNI Protocol Interaction}:
            \list
                \li \b {Left Click}: activates the tray item (\c modelData.activate())
                \li \b {Right Click}: opens the application's native context menu (\c modelData.menu.open())
                \li \b {Middle Click}: triggers secondary action (\c modelData.secondaryActivate())
            \endlist
    \endlist

    Example usage:
    \code
    import "../components/bar"

    TopBar {
        TrayPill {}
    }
    \endcode
*/

WidgetBase {
    id: root 
    type: "tray"
    /*! \internal disables the parent capsule's MouseArea so children icon can handle pointer events */
    interactive: false 
    
    /*! \internal enables automatic collapse when hasContent == false */
    autoHide: true
    hasContent: SystemTray.items.values.length > 0


    Repeater {
        model: SystemTray.items.values

        delegate: Item {
            required property var modelData
            width: 18
            height: 18

            // tray icon renderer
            Image {
                anchors.fill: parent
                source: modelData.icon.includes("?path=") || modelData.icon.startsWith("image://")
                        ? modelData.icon : Quickshell.iconPath(modelData.icon, true)
                sourceSize: Qt.size(18, 18)
                fillMode: Image.PreserveAspectFit
                smooth: true
                //asynchronous: true
            }

            // handles interaction 
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) modelData.activate()
                    else if (mouse.button === Qt.RightButton) { if (modelData.menu) modelData.menu.open(mouse.x, mouse.y) }
                    else if (mouse.button === Qt.MiddleButton) modelData.secondaryActivate()
                }
            }
        }
    }
}
