pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/*!
    \qmltype WeatherService
    \inherits Singleton
    \inqmlmodule services
    \brief local weather scraper and periodic temperature update daemon
*/

Singleton {
    id: root

    readonly property int refreshIntervalMs: 600000 // 10 min
    readonly property string scriptPath: Quickshell.env("HOME") + Settings.weatherScriptPath

    property string icon: ""
    property string temperature: "--°"
    property string tooltip: "Loading.."
    property bool loading: true
    property bool hasError: false

    function refresh() {
        if (!weatherProcess.running) weatherProcess.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: weatherProcess
        command: [root.scriptPath]

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
                    console.warn("[WeatherService] parsing error:", e)
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