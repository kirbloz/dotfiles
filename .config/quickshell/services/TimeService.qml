pragma Singleton
import QtQuick
import Quickshell

/*!
    \qmltype TimeService
    \inherits Singleton
    \inqmlmodule services
    \brief central system clock and localized date/time formatter
*/


Singleton {
    id: root

    property real currentTimestamp: Date.now()
    readonly property date currentDate: new Date(currentTimestamp)
    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    readonly property var monthNames: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dec"]

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentTimestamp = Date.now()
    }

    function formatTime(date, showSeconds) {
        if (!date) date = root.currentDate
        const hours = String(date.getHours()).padStart(2, '0')
        const minutes = String(date.getMinutes()).padStart(2, '0')
        const seconds = String(date.getSeconds()).padStart(2, '0')
        const dayName = dayNames[date.getDay()]
        const dayNum = String(date.getDate()).padStart(2, '0')
        const monthName = monthNames[date.getMonth()]

        if (showSeconds)
            return hours + ":" + minutes + ":" + seconds
        return hours + ":" + minutes + "   " + dayName + " " + dayNum + " " + monthName
    }

    function formatDate(date) {
        if (!date) date = root.currentDate
        return dayNames[date.getDay()] + " " + String(date.getDate()).padStart(2, '0') + " " + monthNames[date.getMonth()]
    }

    function formatTimeOnly(date) {
        if (!date) date = root.currentDate
        return String(date.getHours()).padStart(2, '0') + ":" + String(date.getMinutes()).padStart(2, '0')
    }

    function getSecondsSinceEpoch() {
        return Math.floor(currentTimestamp / 1000)
    }

    function isLeapYear(year) {
        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
    }
}