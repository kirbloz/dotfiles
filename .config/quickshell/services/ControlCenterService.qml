import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property var anchorItem: null
    property var anchorScreen: null

    function openFrom(item, screen) {
        anchorItem = item;
        anchorScreen = screen;
        open = true;
    }

    function close() {
        open = false;
    }

    function toggleFrom(item, screen) {
        if (open)
            close();
        else
            openFrom(item, screen);
    }

}
