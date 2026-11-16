import "../.."
import "../commons"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

/* not integrated anywhere rn*/

ColumnLayout {
    id: recWidget
    Layout.fillWidth: true
    spacing: 12

    property bool choosingScreen: false
    
    RowLayout {
        Layout.fillWidth: true

        Text {
           text: {
                if (ScreenRecorder.recording) return "Recording...";
                if (ScreenRecorder.counting) return "Starting in " + ScreenRecorder.countdown + "s";
                if (recWidget.choosingScreen) return "Select Monitor";
                return "Record Screen";
            }
            color: ScreenRecorder.recording ? Theme.grvRed : Theme.fg0
            font.bold: true
            Layout.fillWidth: true
        }

        Rectangle {
            visible: !recWidget.choosingScreen
            implicitWidth: 32
            implicitHeight: 32
            radius: Theme.radius
            color: Theme.bg1
            
            Text {
                anchors.centerIn: parent
                text: "📁"
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ScreenRecorder.openDir()
            }
        }

    }

    GridLayout {
        Layout.fillWidth: true
        visible: !ScreenRecorder.recording && !ScreenRecorder.counting && !recWidget.choosingScreen
        columns: 3
        rowSpacing: 8
        columnSpacing: 8

        // Toggle Microfono
        QuickButton {
            Layout.fillWidth: true
            text: ScreenRecorder.micOn ? "󰗋 Mic" : "󰻔 Mic"
            active: ScreenRecorder.micOn
            onClicked: ScreenRecorder.micOn = !ScreenRecorder.micOn
        }

        QuickButton {
            Layout.fillWidth: true
            text: ScreenRecorder.desktopOn ? "󰓃 System" : "󰓄 System"
            active: ScreenRecorder.desktopOn
            onClicked: ScreenRecorder.desktopOn = !ScreenRecorder.desktopOn
        }

        QuickButton {
            Layout.fillWidth: true
            text: ScreenRecorder.captureCursor ? "󰍽 Cur" : "󰍾 Cur"
            active: ScreenRecorder.captureCursor
            onClicked: ScreenRecorder.captureCursor = !ScreenRecorder.captureCursor
        }

        QuickButton {
            Layout.fillWidth: true
            text: " " + ScreenRecorder.fps + " FPS"
            active: true
            onClicked: ScreenRecorder.fps = (ScreenRecorder.fps === 60 ? 30 : 60)
        }

        QuickButton {
            Layout.fillWidth: true
            Layout.columnSpan: 2 
            text: "󰷜 " + ScreenRecorder.quality
            active: true
            onClicked: {
                var q = ScreenRecorder.quality;
                if (q === "medium") ScreenRecorder.quality = "high";
                else if (q === "high") ScreenRecorder.quality = "ultra";
                else if (q === "ultra") ScreenRecorder.quality = "lossless";
                else ScreenRecorder.quality = "medium";
            }
        }
    }

    StackLayout {
        Layout.fillWidth: true
        currentIndex: {
            if (ScreenRecorder.recording || ScreenRecorder.counting) return 2; 
            if (recWidget.choosingScreen) return 1;
            return 0; 
        }

        // View 0
        RowLayout {
            spacing: 8

            QuickButton {
                Layout.fillWidth: true
                text: "Full Screen"
                
                hoverColor: Theme.grvRed
                enabled: !ScreenRecorder.busy
                opacity: enabled ? 1 : 0.5
                onClicked: {
                    if (ScreenRecorder.monitors.length > 1) {
                        choosingScreen = true; 
                    } else {
                        var mon = ScreenRecorder.monitors.length === 1 ? ScreenRecorder.monitors[0].name : "screen";
                        ScreenRecorder.prepareScreen(mon);
                    }
                }
            }

            QuickButton {
                Layout.fillWidth: true
                text: "Area / Window"
                hoverColor: Theme.grvRed
                enabled: !ScreenRecorder.busy
                opacity: enabled ? 1 : 0.5
                onClicked: ScreenRecorder.prepareWindow()
            }
        }

        // View 1
        ColumnLayout {
            spacing: 8
            
            RowLayout {
                spacing: 8
                Repeater {
                    model: ScreenRecorder.monitors
                    QuickButton {
                        Layout.fillWidth: true
                        text: modelData.name 
                        onClicked: {
                            ScreenRecorder.prepareScreen(modelData.name);
                            choosingScreen = false;
                        }
                    }
                }
            }

            QuickButton {
                Layout.fillWidth: true
                text: "Cancel"
                onClicked: choosingScreen = false
            }
        }

        QuickButton {
            Layout.fillWidth: true
            text: ScreenRecorder.counting ? "Cancel Countdown" : "Stop Recording"
            active: true
            activeColor: Theme.grvRed 
            onClicked: {
                if (ScreenRecorder.recording) ScreenRecorder.stop();
                if (ScreenRecorder.counting) ScreenRecorder.cancel();
            }
        }
    }

    // --- COMPONENTI INTERNI (per mantenere il codice pulito) ---
    
    // Componente base per i piccoli toggle delle impostazioni
    component SettingToggle : Rectangle {
        property string icon: ""
        property string label: ""
        property bool active: false
        signal clicked()
        
        Layout.fillWidth: true
        implicitHeight: 34
        radius: Theme.radius
        color: active ? Theme.bg1 : Qt.darker(Theme.bg1, 1.5)
        border.width: 1
        border.color: active ? Theme.grvYellow : "transparent"

        RowLayout {
            anchors.centerIn: parent
            spacing: 4
            Text { text: icon; font.pixelSize: 12 }
            Text { text: label; color: active ? Theme.fg0 : "gray"; font.pixelSize: 12 }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    // Componente base per i pulsanti di azione larghi
    component ActionBtn : Rectangle {
        property string text: ""
        property color textColor: Theme.fg0
        signal clicked()
        
        Layout.fillWidth: true
        implicitHeight: 38
        radius: Theme.radius
        color: Theme.bg1
        opacity: enabled ? 1 : 0.5

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.textColor
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
