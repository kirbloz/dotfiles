import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspacesContainer
    spacing: 6

    property int minWorkspaces: 3

    // highest id that really exists (active)
    readonly property int highestWsId: {
        const ids = Hyprland.workspaces.values
            .map(w => w.id)
            .filter(id => id > 0)
        return ids.length > 0 ? Math.max(...ids) : 0
    }

    readonly property int workspaceCount: Math.max(minWorkspaces, highestWsId)


    Repeater {
        model: workspaceCount
        delegate: WorkspaceBtn {
            wsId: index + 1
        }
    }
}
