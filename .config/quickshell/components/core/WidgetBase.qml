import qs
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root


    readonly property var screen: (parent && parent.screen) ? parent.screen : (Window.window ? Window.window.screen : null)
    readonly property var mouseArea: mouseArea
    // contract data
    /*! \qmlproperty string WidgetBase::type
        unique widget id (es. "clock", "battery", "tray"). */
    property string type: "widget"
    /*! \qmlproperty string WidgetBase::tooltipText
        text inside the tooltip activated when overing the pill */
    property string tooltipText: ""
    /*! \qmlproperty string WidgetBase::severity
        semantic state for deciding border and background colors
        valid values:
        \list
            \li \c "normal"
            \li \c "warning"
            \li \c "critical"
            \li \c "active"
        \endlist */
    property string severity: "normal"
    // behavior
     /*! \qmlproperty bool WidgetBase::interactive
        if false, deactivates global MouseArea letting children handle clicks */
    property bool interactive: true
    /*! \qmlproperty bool WidgetBase::enableHover
        if true, lightens/darkens the pill on mouse hover */
    property bool enableHover: true
    /*! \qmlproperty bool WidgetBase::autoHide
        if true, collapses pill width to 0 and hides it when hasContent is false */
    property bool autoHide: false
    /*! \qmlproperty bool WidgetBase::hasContent
        flag used by autoHide (i.e. hiding tray pill when there are no icons)*/
    property bool hasContent: true
    /*! \qmlproperty alias WidgetBase::content
        default property; every child ends up in this internal RowLayout 
        */
    default property alias content: contentRow.data

    property int margins: 10
    property int spacing: 6
    // dynamic palette
    readonly property color currentBg: {
        if (!interactive)
            return Theme.darkgray;

        if (mouseArea.pressed)
            return Theme.fg0;

        if (severity === "critical")
            return Theme.grvRedDim;

        if (severity === "warning")
            return Theme.grvyellowDim;

        if (severity === "active")
            return Theme.hover;

        if (enableHover && mouseArea.containsMouse)
            return Theme.bg3;

        return Theme.darkgray;
    }
    readonly property color currentBorder: {
        if (severity === "critical")
            return Theme.grvRed;

        if (severity === "warning")
            return Theme.grvYellow;

        if (severity === "active")
            return Theme.grvAqua;

        return Theme.bg3;
    }
    
    /*! \qmlsignal WidgetBase::clicked(var mouse)
        emitted when left clicked
        */
    signal clicked(var mouse)
    /*! \qmlsignal WidgetBase::rightClicked()
        emitted when right clicked
        */
    signal rightClicked()
    /*! \qmlsignal WidgetBase::wheelScrolled(int delta)
        emitted when wheel scrolled (positive = up, negative = down)
        */
    signal wheelScrolled(int delta)

    // geometry
    visible: !autoHide || hasContent
    implicitWidth: visible ? (contentRow.implicitWidth + margins * 2) : 0
    implicitHeight: visible ? 30 : 0
    radius: height / 2

    // colors
    color: currentBg
    border.color: currentBorder
    border.width: severity !== "normal" ? 1 : 0

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: root.spacing
    }

    /*! \qmlmethod void WidgetBase::togglePopup(var popupItem)
        computes global coordinates for pill and calls toggleFrom() on popup object
        */
    function togglePopup(popupItem) {
        if (!popupItem) return;
        const globalPos = root.mapToItem(null, 0, 0);
        popupItem.toggleFrom(root, globalPos);
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.interactive && root.visible
        hoverEnabled: root.enableHover
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) root.clicked(mouse);
            else if (mouse.button === Qt.RightButton) root.rightClicked();
        }

        onWheel: (wheel) => root.wheelScrolled(wheel.angleDelta.y)
    }

    Behavior on color {
        ColorAnimation {
            duration: 140
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 140
        }

    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }

    }

}
