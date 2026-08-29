import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io
import ".."

// "bentornato": avatar circolare + saluto in base all'ora
// Se l'immagine non si trova, cade su un cerchio con l'iniziale del nome.
RowLayout {
    id: greeterRoot

    property string username: ""
    // Sovrascrivi questa property da ControlCenter.qml se il path di
    // default non esiste sulla tua distro, es:
    // Greeter { avatarSource: "file:///home/tuoutente/.face" }
    property string avatarSource: username !== "" ? ("file:///var/lib/AccountsService/icons/" + username) : ""

    function greetingText() {
        const h = new Date().getHours();
        if (h < 6)
            return "Still awake?";

        if (h < 12)
            return "Hello";

        if (h < 18)
            return "What's poppin'";

        return "Good evening Sir";
    }

    Layout.fillWidth: true
    spacing: 12

    Process {
        id: whoami

        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                return greeterRoot.username = line.trim();
            }
        }

    }

    Item {
        // Fallback: cerchio con iniziale se l'avatar non esiste/non è leggibile
        id: avatarBox

        implicitWidth: 52
        implicitHeight: 52

        Image {
            id: avatarImg

            anchors.fill: parent
            source: greeterRoot.avatarSource
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            asynchronous: true
            smooth: true
            mipmap: true
            // supersample the og img, the upscaled img wont look grainy
            sourceSize: Qt.size(avatarBox.width * 3, avatarBox.height * 3)
            cache: false
            // attach mask effect to img layer
            layer.enabled: true
            layer.smooth: true
            // render texture in supersample
            layer.textureSize: Qt.size(avatarBox.width * 3, avatarBox.height * 3)
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: avatarMask
            }

        }

        // actual mask: same area, transparent, placeholder for circle
        Rectangle {
            id: avatarMask
            anchors.fill: avatarImg
            radius: width / 2
            visible: false
            layer.enabled: true
            layer.smooth: true
            layer.textureSize: Qt.size(width * 3, height * 3)
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.bg3
            border.color: Theme.grvYellow
            border.width: 1
            visible: avatarImg.status !== Image.Ready

            Text {
                anchors.centerIn: parent
                text: greeterRoot.username.length > 0 ? greeterRoot.username[0].toUpperCase() : "?"
                color: Theme.grvYellow
                font.pixelSize: 20
                font.bold: true
                font.family: Theme.fontFamily
            }

        }

        // Bordo decorativo, sempre sopra (immagine o fallback)
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: Theme.grvYellow
            border.width: 1
        }

        // online dot, just for aesthetic
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Theme.grvAqua
            border.color: Theme.bg1
            border.width: 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

    }

    ColumnLayout {
        spacing: 0

        Text {
            text: greeterRoot.greetingText()
            color: Theme.fgMuted
            font.pixelSize: 11
            font.family: Theme.fontFamily
        }

        Text {
            text: greeterRoot.username
            color: Theme.fg0
            font.bold: true
            font.pixelSize: 15
            font.family: Theme.fontFamily
        }

    }

}
