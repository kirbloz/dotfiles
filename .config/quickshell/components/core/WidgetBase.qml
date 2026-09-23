import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: widgetBase

    property string type: "widget"
    property string label: ""
    property real fontSize: 14

    property color bgBase: Theme.darkgray
    property color bgHover: Theme.bg3
    property color bgPressed: Theme.fg0
    property color textMain: Theme.fg0
    property color textMuted: Theme.fgMuted
    property color borderColor: Theme.bg4
    property real borderWidth: 0

    property bool enableHover: false   // opt-in: la maggior parte delle pill è a colore fisso
    property bool enablePressed: true
    property bool interactive: true    // false = niente MouseArea automatica, gestisci tu i click

    property int spacing: 6
    property int margins: 12

    default property alias content: contentRow.data   // finisce nel RowLayout
    property alias overlay: overlayLayer.data          // copre l'intera pill, fuori dal layout

    signal clicked()

    implicitWidth: contentRow.implicitWidth + margins * 2
    implicitHeight: 30
    radius: height / 2

    color: {
        if (enablePressed && mouseArea.pressed) return bgPressed
        if (enableHover && mouseArea.containsMouse) return bgHover
        return bgBase
    }
    Behavior on color { ColorAnimation { duration: 150 } }

    border.color: borderColor
    border.width: borderWidth

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: widgetBase.spacing
    }

    Item {
        id: overlayLayer
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: -1                              // sta sotto contentRow/overlay: chi ha una MouseArea propria vince
        enabled: widgetBase.interactive
        hoverEnabled: widgetBase.enableHover
        cursorShape: Qt.PointingHandCursor
        onClicked: widgetBase.clicked()
    }
}