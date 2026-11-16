import qs
import qs.services
import "../core"
import "../commons"
import QtQuick

/*! \qmltype WeatherPill
    \inherits WidgetBase
    \brief polls WeatherService for data and displays it
    */
WidgetBase {
    id: root
    type: "weather"

    onClicked: WeatherService.refresh()

    property string tooltipText: ""

    Text {
        text: WeatherService.loading ? "…" : WeatherService.hasError ? "⚠ ERR" : WeatherService.icon + "   " + WeatherService.temperature
        color: Theme.fg0
        font.pixelSize: 14
        font.bold: true
    }

    CustomTooltip {
        anchorItem: root
        
        show: {
            tooltipText = WeatherService.tooltip;
            if(root.mouseArea.containsMouse && root.tooltipText.length > 0)
                return true
            else false
        }
        text: root.tooltipText
    }
}