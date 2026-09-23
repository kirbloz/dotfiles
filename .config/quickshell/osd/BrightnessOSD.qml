import "../components/osd" 
import "../services" as QsServices
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland


BubbleOSD{
    id:root
    readonly property var brt: QsServices.BrightnessService
    property int prevBright: -1

    icon: percentage > 66 ? "  󰃠" : percentage > 33 ? "  󰃟" : "  󰃞"
    valueText: Math.round(percentage) + "%"
    percentage: brt.percentage
    
    Component.onCompleted: {
        prevBright = brt.percentage;
    }

    Connections {
        target: brt

        function onPercentageChanged() {
            if (prevBright !== -1 && brt.percentage !== prevBright)
                root.show();
            prevBright = brt.percentage;
        }
    }
}
