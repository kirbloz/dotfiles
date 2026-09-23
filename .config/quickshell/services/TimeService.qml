pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property real currentTimestamp: Date.now()
    readonly property date currentDate: new Date(currentTimestamp)

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
        const dayName = ["Dom","Lun","Mar","Mer","Gio","Ven","Sab"][date.getDay()]
        const dayNum = String(date.getDate()).padStart(2, '0')
        const monthNames = ["Gen","Feb","Mar","Apr","Mag","Giu","Lug","Ago","Set","Ott","Nov","Dic"]
        const monthName = monthNames[date.getMonth()]

        if (showSeconds)
            return hours + ":" + minutes + ":" + seconds
        return hours + ":" + minutes + "   " + dayName + " " + dayNum + " " + monthName
    }

    function formatDate(date) {
        if (!date) date = root.currentDate
        const dayNames = ["Dom","Lun","Mar","Mer","Gio","Ven","Sab"]
        const monthNames = ["Gen","Feb","Mar","Apr","Mag","Giu","Lug","Ago","Set","Ott","Nov","Dic"]
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