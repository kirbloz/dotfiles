pragma Singleton
import QtQuick


QtObject {
    id: root

    // global registry for popups
    property var networkPopup: null
    property var controlCenterPopup: null
    property var dashboardPopup: null
    property var notifCenterPopup: null
    property var selfTrackPopup: null
    property var calendarPopup: null

    function register(name, popupInstance) {
        if (name === "network")
            networkPopup = popupInstance;
        else if (name === "controlCenter")
            controlCenterPopup = popupInstance;
        else if (name === "dashboard")
            dashboardPopup = popupInstance;
        else if (name === "notifications")
            notifCenterPopup = popupInstance;
        else if (name === "selfTrack")
            selfTrackPopup = popupInstance;
        else if (name === "calendar")
            calendarPopup = popupInstance;
    }

    function findScreen(item) {
        if (!item)
            return null;

        if (item.screen)
            return item.screen;

        if (item.targetScreen && item.targetScreen)
            return item.targetScreen;

        // fallback up parents tree
        let p = item.parent;
        while (p) {
            if (p.screen)
                return p.screen;

            if (p.targetScreen)
                return p.targetScreen;

            p = p.parent;
        }
        console.warn("[PopupService] couldnt find screen");
        return null;
    }

    function _get(name) {
        if (name === "network")
            return networkPopup;

        if (name === "controlCenter")
            return controlCenterPopup;

        if (name === "dashboard")
            return dashboardPopup;

        if (name === "notifications")
            return notifCenterPopup;

        if (name === "selfTrack")
            return selfTrackPopup;

        if (name === "calendar")
            return calendarPopup;

        return null;
    }

    function toggle(name, anchorItem) {
        let popup = _get(name);
        if (!popup) {
            console.error("[PopupService] no popups named:", name);
            return null;
        }
        if (anchorItem) {
            // detects screen
            let detectedScreen = findScreen(anchorItem);
            if (!detectedScreen && anchorItem.parent)
                detectedScreen = anchorItem.parent.targetScreen || anchorItem.parent.screen;
            
            if (detectedScreen) {
                popup.screen = detectedScreen;
            }
            const globalPos = anchorItem.mapToItem(null, 0, 0);
            popup.toggleFrom(anchorItem, globalPos);
        }
        popup.isOpen = !popup.isOpen;
    }


}
