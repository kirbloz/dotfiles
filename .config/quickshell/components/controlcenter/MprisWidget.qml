import qs
import qs.services
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

/*!
    \qmltype MprisWidget
    \inherits Rectangle
    \inqmlmodule components.dashboard
    \brief compact MPRIS media controller card with album art, hover-marquee title, interactive seekbar, and playback controls

    MprisWidget provides an integrated media player interface backed by \l MprisService; it automatically hides itself when no media player is actively registered in the system

    key features:
    \list
        \li \b {Duration Caching}: Retains \l lastValidLength during track transitions to prevent the seekbar from collapsing or flickering when media players temporarily report zero length
        \li \b {Interactive Hover Marquee}: long song titles that exceed container boundaries are clipped and hovering over the title triggers a smooth, continuous marquee animation
        \li \b {Seekable Progress Bar}: clicking along the progress bar seeks playback via \c playerctl DEBUG not working 
        \li \b {Album Art}: dynamically loads local or remote album artwork, clipping the image to match theme corner radii using a hardware-accelerated \c MultiEffect shader
    \endlist

    Example usage:
    \code
    import "../components/dashboard"

    MprisWidget {
        Layout.fillWidth: true
    }
    \endcode
*/

Rectangle {
    id: mprisRoot

    property real lastValidLength: 0
    
    readonly property real trackLength: {
        if (MprisService.length && !isNaN(MprisService.length) && MprisService.length > 0)
            return MprisService.length;
        return lastValidLength > 0 ? lastValidLength : 0;
    }

    readonly property real currentPosition: {
        var pos = MprisService.position;
        if (!pos || isNaN(pos) || pos < 0) return 0;
        if (trackLength > 0) return Math.min(pos, trackLength);
        return pos;
    }

    readonly property real progressFraction: {
        if (trackLength <= 0) return 0;
        return Math.max(0, Math.min(1, currentPosition / trackLength));
    }
    
    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds < 0)
            return "0:00";

        var m = Math.floor(seconds / 60);
        var s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    implicitHeight: MprisService.currentPlayer ? 100 : 0
    visible: MprisService.currentPlayer !== null
    color: Theme.bg2
    radius: Theme.radius
    border.color: Theme.bg3
    border.width: 1
    clip: true
    Component.onCompleted: MprisService.monitorPosition = true
    Component.onDestruction: MprisService.monitorPosition = false

    Connections {
        function onLengthChanged() {
            if (MprisService.length > 0)
                mprisRoot.lastValidLength = MprisService.length;

        }

        function onTitleChanged() {
            mprisRoot.lastValidLength = MprisService.length > 0 ? MprisService.length : 0;
        }

        target: MprisService
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // album cover
        Rectangle {
            id: coverContainer

            readonly property string artUrl: {
                var url = MprisService.albumCover;
                if (!url || url === "")
                    return "";

                if (url.startsWith("/"))
                    return "file://" + url;

                return url;
            }

            implicitWidth: 74
            implicitHeight: 74
            radius: Theme.radius
            color: Theme.bg3
            layer.enabled: true

            Image {
                id: coverArt

                anchors.fill: parent
                source: coverContainer.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "󰎈"
                color: Theme.fgMuted
                font.pixelSize: 24
                visible: coverArt.status !== Image.Ready
            }

            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1

                maskSource: ShaderEffectSource {

                    sourceItem: Rectangle {
                        width: coverContainer.width
                        height: coverContainer.height
                        radius: coverContainer.radius
                    }

                }

            }

        }

        // details, bar, controls
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Item {
                id: titleContainer

                Layout.fillWidth: true
                implicitHeight: titleText.implicitHeight
                clip: true

                Text {
                    //elide: Text.ElideRight

                    id: titleText

                    // check overflow distance if title is too long
                    readonly property real overflowDistance: Math.max(0, titleText.implicitWidth - titleContainer.width)

                    //Layout.fillWidth: true
                    text: MprisService.title !== "" ? MprisService.title : "Nothing playing rn.."
                    color: Theme.fg0
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 13

                    // reset marquee
                    Connections {
                        function onContainsMouseChanged() {
                            if (!titleMa.containsMouse) {
                                marqueeAnim.stop();
                                titleText.x = 0;
                            }
                        }

                        target: titleMa
                    }

                    // marquee on hover
                    SequentialAnimation on x {
                        id: marqueeAnim

                        running: titleMa.containsMouse && titleText.overflowDistance > 0
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: 600
                        }

                        NumberAnimation {
                            to: -titleText.overflowDistance
                            // reading speed around 40px/s
                            duration: Math.max(1000, titleText.overflowDistance * 25)
                            easing.type: Easing.Linear
                        }
                        // pause at the end

                        PauseAnimation {
                            duration: 1200
                        }
                        // back at the start

                        NumberAnimation {
                            to: 0
                            duration: 500
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                MouseArea {
                    id: titleMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: titleText.overflowDistance > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onExited: {
                        marqueeAnim.stop();
                        titleText.x = 0;
                    }
                }

            }

            // artist
            Text {
                Layout.fillWidth: true
                text: MprisService.artist !== "" ? MprisService.artist : "Unknown"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            // seekable progress bar and timestamps
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: MprisService.currentPlayer !== null

                Rectangle {
                    id: progressTrack

                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.bg3

                    Rectangle {
                        id: progressFill

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * mprisRoot.progressFraction
                        radius: 3
                        color: Theme.grvYellow

                        Behavior on width {
                            enabled: !progressBarMa.drag.active

                            NumberAnimation {
                                duration: 120
                            }

                        }

                    }

                    MouseArea {
                        // move current listening point
                        id: progressBarMa

                        // FIXME all stupid
                        enabled: false

                        anchors.fill: parent
                        hoverEnabled: true
                        //cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (!MprisService.currentPlayer)
                                return ;

                            var len = mprisRoot.trackLength;
                            if (len <= 0)
                                return ;

                            var frac = Math.max(0, Math.min(1, mouse.x / progressTrack.width));
                            var targetPos = frac * MprisService.len;
                            
                            // playerctl is browser compatible and doesnt shit itself
                            try {
                                Quickshell.execDetached(["playerctl", "position", targetPos.toFixed(1)]);
                            } catch (e) {
                            }
                            
                            // internal quickshell command as a fallback (tho its stupider)
                            try {
                                if (MprisService.currentPlayer.canSeek && MprisService.currentPlayer.positionSupported)
                                    MprisService.currentPlayer.position = targetPos;

                            } catch (e) {
                            }
                            
                            // visual feedback
                            MprisService.position = targetPos;
                        }
                    }

                }

                // time rn
                Text {
                    text: mprisRoot.formatTime(mprisRoot.currentPosition) + " / " + mprisRoot.formatTime(mprisRoot.trackLength)
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

            }

            // controls
            RowLayout {
                spacing: 16
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "󰒮"
                    color: (MprisService.canGoPrevious ?? true) ? Theme.fg1 : Theme.fgMuted
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (MprisService.canGoPrevious ?? true) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: MprisService.previous()
                    }

                }

                Text {
                    text: MprisService.playing ? "󰏤" : "󰐊"
                    color: Theme.grvYellow
                    font.pixelSize: 20

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.togglePlaying()
                    }

                }

                Text {
                    text: "󰒭"
                    color: (MprisService.canGoNext ?? true) ? Theme.fg1 : Theme.fgMuted
                    font.pixelSize: 16

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: (MprisService.canGoNext ?? true) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: MprisService.next()
                    }

                }

            }

        }

    }

}
