import QtQuick

Rectangle {
    id: root

    property bool isOpen: false
    property color bgColor: "#222222"
    property color borderColor: "#ffcc00"
    
    default property alias content: contentArea.data
    property int targetWidth: contentArea.childrenRect.width + 32
    property int targetHeight: contentArea.childrenRect.height + 32
    

    width: isOpen ? targetWidth : 0
    height: isOpen ? targetHeight : 0
    color: bgColor
    radius: isOpen ? 12 : height / 2
    border.color: isOpen ? borderColor : "#444444"
    border.width: 1

    // Contenitore per il contenuto esterno
    Item {
        id: contentArea

        anchors.fill: parent
        anchors.margins: 14
        opacity: root.isOpen ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }

        }

    }

    Behavior on width {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutExpo
        }

    }

    Behavior on height {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutExpo
        }

    }

    Behavior on radius {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutExpo
        }

    }

}
