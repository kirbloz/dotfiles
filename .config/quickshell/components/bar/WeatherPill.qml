import "../.."
import "../../services"
import QtQuick

Rectangle {
    id: root

    implicitHeight: 30
    implicitWidth: label.implicitWidth + 24
    radius: height / 2
    color: Theme.darkgray

    Text {
        id: label
        anchors.centerIn: parent
        text: WeatherService.loading ? "…" : WeatherService.hasError ? "⚠ ERR" : WeatherService.icon + " " + WeatherService.temperature
        color: Theme.fg0
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: WeatherService.refresh()
    }

}
