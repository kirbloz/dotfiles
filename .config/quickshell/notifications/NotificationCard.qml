import qs
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: cardRoot

    property var notif: null
    property string appName: notif ? (notif.appName || "System") : "System"
    property string summary: notif ? notif.summary : ""
    property string body: notif ? notif.body : ""
    property string time: ""
    property bool isCritical: notif ? (notif.urgency === "CRITICAL") : false
    property bool showClose: true

    signal closed()

    implicitHeight: mainLayout.implicitHeight + 20
    color: Theme.bg2
    radius: Theme.radius
    border.color: isCritical ? Theme.grvRed : Theme.bg3
    border.width: 1
    clip: true

    // red band for critical notifs
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 4
        color: Theme.grvRed
        visible: isCritical
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: isCritical ? 14 : 10
        spacing: 6

        // ---- header ----
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: appName
                color: isCritical ? Theme.grvRed : Theme.grvYellow
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 11
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: time
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                visible: text !== ""
            }

            // close notification button
            Rectangle {
                implicitWidth: 18
                implicitHeight: 18
                radius: 3
                color: closeMouse.containsMouse ? Theme.hover : "transparent"
                visible: cardRoot.showClose

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Theme.fgMuted
                    font.pixelSize: 10
                }

                MouseArea {
                    id: closeMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cardRoot.closed();
                        if (notif && typeof notif.dismiss === "function")
                            notif.dismiss();

                    }
                }
            }
        }

        // summary
        Text {
            Layout.fillWidth: true
            text: summary
            color: Theme.fg0
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 13
            elide: Text.ElideRight
        }

        // body
        Text {
            Layout.fillWidth: true
            text: body
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            visible: text !== ""
        }

    }

}
