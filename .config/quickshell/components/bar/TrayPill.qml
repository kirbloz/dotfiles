import "../.."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: trayPill

    visible: true //SystemTray.items.length > 0
    implicitHeight: 34
    implicitWidth: layout.implicitWidth + 20
    radius: height / 2
    color: Theme.darkgray

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: SystemTray.items

            delegate: Item {
                width: 18
                height: 18

                Image {
                    anchors.fill: parent
                    source: modelData.icon.includes("?path=") || modelData.icon.startsWith("image://") ? modelData.icon : Quickshell.iconPath(modelData.icon, true) // true = fallback se non trovata
                    sourceSize: Qt.size(18, 18)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            if (modelData.menu)
                                modelData.menu.open(mouse.x, mouse.y);

                        } else if (mouse.button === Qt.MiddleButton) {
                            modelData.secondaryActivate();
                        }
                    }
                }

            }

        }

    }

}
