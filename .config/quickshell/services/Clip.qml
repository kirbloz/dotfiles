/*
 *  creds: https://github.com/vmaltarello/bezel-hyprland/tree/main
 */

/*! TODO implement a popup for this
    \qmltype Clip
    \inherits Singleton
    \inqmlmodule services
    \brief Clipboard history manager interfacing with cliphist and wl-copy
*/

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var items: []

    function refresh() { 
        if (!list.running) list.running = true; 
    }

    function copy(line) { 
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "_", line]); 
    }

    function remove(line) {
        Quickshell.execDetached(["sh", "-c", 'printf "%s" "$1" | cliphist delete', "_", line]);
        items = items.filter(i => i.line !== line);
    }

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.items = text.split("\n").filter(l => l.length > 0).slice(0, 150).map(l => {
                    const t = l.split("\t").slice(1).join("\t");
                    return { 
                        line: l, 
                        text: t.startsWith("[[ binary") ? ("Image " + (t.match(/\d+x\d+/)?.[0] ?? "")) : t 
                    };
                });
            }
        }
    }
}