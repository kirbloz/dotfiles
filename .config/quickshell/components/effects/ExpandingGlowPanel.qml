import "../.."
import "../effects"
import QtQuick
import QtQuick.Effects

Item {
    id: root

    property bool expanded: false
    property real collapsedScale: 0.01
    property color glowColor: Theme.grvYellow
    property color borderColor: Theme.grvYellow
    property color backgroundColor: Qt.rgba(Theme.bg1.r, Theme.bg1.g, Theme.bg1.b, 0.9)
    property real panelRadius: Theme.radius + 4
    property int growthOrigin: Item.Top
    
    // parent component can inject content here
    default property alias content: contentContainer.data

    transformOrigin: growthOrigin
    scale: expanded ? 1 : collapsedScale

    Behavior on scale {
        NumberAnimation {
            duration: root.expanded ? 350 : 200
            easing.type: root.expanded ? Easing.OutBack : Easing.InOutQuad
            easing.overshoot: root.expanded ? 0.8 : 0
        }
    }

    // glow
    Rectangle {
        id: glowSource
        anchors.fill: parent
        color: "transparent"
        border.color: root.glowColor
        border.width: 4
        radius: root.panelRadius
        visible: false
    }

    MultiEffect {
        source: glowSource
        anchors.fill: glowSource
        blurEnabled: true
        blurMax: 32
        blur: 1.0
        autoPaddingEnabled: true
    }

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: root.backgroundColor
        radius: root.panelRadius
        border.color: root.borderColor
        border.width: 0.5

        CrtScanlines {
            anchors.fill: parent
            anchors.margins: 2 // avoid weird corners
        }
        
        
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        opacity: root.expanded ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
}