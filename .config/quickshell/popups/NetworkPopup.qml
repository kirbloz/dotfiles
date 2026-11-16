import qs
import qs.services
import "../components/commons"
import "../components/core"
import "../components/network"
import QtQuick
import QtQuick.Layouts

/*
    NetworkPopup connects NetworkService and UI popup acts as a controller, .activate(net) translates view click to service call
    - upon opening scanWifi is called -> signal is captured and wifiModel updated
*/


BasePopup {
    id: root
    ipcTarget: "network"

    // specific properties
    property string pendingSsid: ""
    property string attemptingSsid: ""
    readonly property bool promptOpen: pendingSsid.length > 0

    glowColor: Theme.grvYellow

    onOpened: NetworkService.scanWifi()
    onClosed: closePrompt()

     function activate(net) {
        if (!net || !net.ssid) return;

        NetworkService.clearConnectError();
        const isCurrent = net.inUse || (NetworkService.netType === "WIFI" && NetworkService.connectedWifi === net.ssid);
        if (isCurrent) {
            closePrompt();
            NetworkService.disconnectWifi();
            return;
        }
        if (net.saved) {
            closePrompt();
            NetworkService.connectToWifi(net.ssid, "");
            return;
        }
        if (!net.secured) {
            closePrompt();
            NetworkService.connectToWifi(net.ssid, "");
            return;
        }
        closePrompt();
        root.attemptingSsid = net.ssid;
        NetworkService.connectToWifi(net.ssid, "");
    }

    function closePrompt() {
        root.attemptingSsid = "";
        root.pendingSsid = "";
        if (typeof prompt !== "undefined" && prompt) prompt.clear();
    }

    // esc closes prompt -> if no prompts open, basepopup will intercept the event and close the widget per se
    
    Connections {
        target: NetworkService
        function onConnectFinished(success) {
            if (success) {
                root.attemptingSsid = "";
                root.closePrompt();
            } else {
                if (root.attemptingSsid !== "") {
                    NetworkService.clearConnectError();
                    root.pendingSsid = root.attemptingSsid;
                    root.attemptingSsid = "";
                    Qt.callLater(() => {
                        if (typeof prompt !== "undefined" && prompt) {
                            prompt.clear();
                            prompt.focusInput();
                        }
                    });
                }
            }
        }
    }

    // content for BasePopup to put inside its CrtPanel
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Keys.onEscapePressed: (event) => {
        if (root.promptOpen) {
            root.closePrompt();
            event.accepted = true;
        }
    }


        // header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Network UI"
                color: Theme.fg0
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            GlyphButton {
                glyph: Glyphs.refresh
                onClicked: NetworkService.scanWifi()
            }

            GlyphButton {
                glyph: Glyphs.close
                color: Theme.fgMuted
                pixelSize: 15
                onClicked: root.isOpen = false
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            glyph: NetworkService.wifiEnabled ? Glyphs.wifiFull : Glyphs.wifiOff
            label: "Wi-Fi Adapter"
            checked: NetworkService.wifiEnabled
            onToggled: (val) => NetworkService.setWifiEnabled(val)
        }


        // separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.grvYellow
            opacity: 0.7
        }

        ConnectionCard {
            Layout.fillWidth: true
            visible: NetworkService.netType !== "DISCONNECTED"
            glyph: NetworkService.netType === "WIFI" ? Glyphs.wifi(NetworkService.sigStrength) : Glyphs.ethernet
            title: NetworkService.netType === "WIFI" ? NetworkService.connectedWifi : NetworkService.ifName
            subtitle: "IP: " + NetworkService.deviceIp + "  |  GW: " + NetworkService.gatewayIp
        }

        PasswordPrompt {
            id: prompt
            Layout.fillWidth: true
            visible: root.promptOpen
            ssid: root.pendingSsid
            busy: NetworkService.connecting
            errorText: NetworkService.connectError
            Layout.preferredHeight: root.promptOpen ? -1 : 0
            onSubmitted: (pwd) => {
                if (root.pendingSsid !== "")
                    NetworkService.connectToWifi(root.pendingSsid, pwd);
            }
            onCancelled: root.closePrompt()
        }

         ListView {
            id: wifiList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            model: NetworkService.networks

            Text {
                anchors.centerIn: parent
                visible: wifiList.count === 0
                text: NetworkService.wifiEnabled ? "No networks found" : "Wi-Fi off"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }

            delegate: WifiNetworkRow {
                required property var modelData
                width: wifiList.width
                ssid: modelData.ssid
                strength: modelData.strength
                secured: modelData.secured
                inUse: modelData.inUse || (NetworkService.connectedWifi === modelData.ssid)
                onActivated: root.activate(modelData)
            }

        } // close list view

    } // close column layout

} // close base popup

