import QtQuick

/*!
    \qmltype CrtScanlines
    \inherits Item
    \inqmlmodule components.effects
    \brief CRT scanline overlay and subtle flicker effect
*/

Item {
    id: root

    Image {
        anchors.fill: parent
        fillMode: Image.Tile
        opacity: 0.2
        smooth: false
        source: "scanline.png"
    }
    /* old method
    Canvas {
        anchors.fill: parent
        opacity: 0.12
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = "#000000";
            ctx.lineWidth = 1;
            for (var y = 0; y < height; y += 4) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
    }*/

    // CRT Flicker
    SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: root.visible && root.opacity > 0.1

        NumberAnimation {
            to: 0.96
            duration: 100
        }

        NumberAnimation {
            to: 1
            duration: 80
        }

        PauseAnimation {
            duration: 4000
        }

    }
}
