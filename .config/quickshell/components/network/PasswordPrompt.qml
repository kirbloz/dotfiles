import qs
import QtQuick
import QtQuick.Layouts

/*!
    \qmltype PasswordPrompt
    \inherits Rectangle
    \inqmlmodule components.network
    \brief inline wifi password input prompt with validation and connect/cancel signals
*/

Rectangle {
    id: root

    property string ssid: ""
    property bool busy: false
    property string errorText: ""

    signal submitted(string password)
    signal cancelled()

    function focusInput() {
        input.forceActiveFocus();
    }

    function clear() {
        input.text = "";
    }

    function submit() {
        if (root.busy || input.text.length === 0)
            return ;
        root.submitted(input.text);
    }

    /*! \internal focus input on visibility */
    onVisibleChanged: {
        if (visible)
            Qt.callLater(root.focusInput);

    }

    implicitHeight: content.implicitHeight + 12
    radius: Theme.radius
    color: Theme.bg2
    border.color: input.activeFocus ? Theme.grvYellow : Theme.bg3
    border.width: 1

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            spacing: 8

            // clickable cell
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: 4
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: Theme.fg0
                    selectionColor: Theme.grvYellow
                    selectedTextColor: Theme.bg1
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                    selectByMouse: true
                    clip: true
                    enabled: !root.busy
                    onAccepted: root.submit()
                    Keys.onEscapePressed: root.cancelled()
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text.length === 0
                    text: "Password for " + root.ssid
                    color: Theme.fgMuted
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }

            }

            Rectangle {
                Layout.preferredWidth: 65
                Layout.preferredHeight: 24
                radius: Theme.radius
                color: (!root.busy && btnArea.containsMouse) ? Theme.grvYellow : Theme.bg3
                opacity: root.busy ? 0.6 : 1

                Text {
                    anchors.centerIn: parent
                    text: root.busy ? "…" : "Connect"
                    color: (!root.busy && btnArea.containsMouse) ? Theme.bg1 : Theme.fg0
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

                MouseArea {
                    id: btnArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }

            }

        }

        Text {
            visible: root.errorText.length > 0
            text: root.errorText
            color: Theme.grvRed
            font.family: Theme.fontFamily
            font.pixelSize: 10
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

    }

}
