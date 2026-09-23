import "../.."
import "../../services"
import "../core"
import QtQuick

WidgetBase {
    id: root
    type: "weather"

    onClicked: WeatherService.refresh()
    

    Text {
        text: WeatherService.loading ? "…" : WeatherService.hasError ? "⚠ ERR" : WeatherService.icon + "   " + WeatherService.temperature
        color: Theme.fg0
        font.pixelSize: 14
        font.bold: true
    }
}