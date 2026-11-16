
// https://github.com/tripathiji1312/quickshell/blob/main/modules/osd/VolumeOSD.qml

import "../components/osd" 
import qs.services as QsServices

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

/*!
    \qmltype VolumeOSD
    \inherits BubbleOSD
    \inqmlmodule osd
    \brief lightweight on-screen display volume feedback
*/

BubbleOSD{
    id:root
     readonly property var audio: QsServices.AudioService
    property int prevVolume: -1
    property bool prevMuted: false

    icon: muted ? "  " : (percentage > 66 ? "  " : percentage > 33 ? "  " : "  ")
    valueText: Math.round(percentage) + "%"
    percentage: audio.percentage
    muted: audio.muted

     Component.onCompleted: {
        prevVolume = audio.percentage;
        prevMuted = audio.muted;
    }

    Connections {
        target: audio

        function onPercentageChanged() {
            if (prevVolume !== -1 && audio.percentage !== prevVolume)
                root.show();
            prevVolume = audio.percentage;
        }

        function onMutedChanged() {
            if (audio.muted !== prevMuted)
                root.show();
            prevMuted = audio.muted;
        }
    }
}

