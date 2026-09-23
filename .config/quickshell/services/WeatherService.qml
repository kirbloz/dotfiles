pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshIntervalMs: 900 * 1000

    property string icon: ""
    property string temperature: "--°"
    property string tooltip: "Caricamento meteo..."
    property bool loading: true
    property bool hasError: false

    function refresh() {
        weatherProcess.running = true
    }

    Component.onCompleted: refresh()

    Process {
        id: weatherProcess
        command: ["/home/giovanni/.local/bin/get-weather"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)
                    const firstSpace = data.text.indexOf(" ")
                    root.icon = data.text.substring(0, firstSpace)
                    root.temperature = data.text.substring(firstSpace + 1)
                    root.tooltip = data.tooltip
                    root.hasError = false
                } catch (e) {
                    console.warn("WeatherService: impossibile parsare l'output dello script:", e)
                    root.hasError = true
                } finally {
                    root.loading = false
                }
            }
        }
    }

    Timer {
        interval: root.refreshIntervalMs
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}