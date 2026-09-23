import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int percentage: 50

    function setPercentage(value) {
        const clamped = Math.max(0, Math.min(100, Math.round(value)));
        root.percentage = clamped; // ottimistico
        setter.command = [scriptPath, "set", String(clamped)];
        setter.running = true;
    }

    function increase() {
        stepper.command = [root.scriptPath, "up"];
        stepper.running = true;
    }

    function decrease() {
        stepper.command = [root.scriptPath, "down"];
        stepper.running = true;
    }

    Component.onCompleted: {
        setter.exited.connect(() => {
            return reader.running = true;
        });
        stepper.exited.connect(() => {
            return reader.running = true;
        });
        // bootstrap: forza la creazione dello state file se non esiste ancora
        bootstrap.command = [scriptPath, "sync"];
        // o il comando equivalente del tuo script
        bootstrap.running = true;
    }

    Process {
        id: bootstrap
    }

    FileView {
        id: stateFile

        path: "/run/user/1000/brightness/brightness.state" // sostituisci con Quickshell.env("UID") se serve dinamico
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const val = parseInt(text().trim());
            if (!isNaN(val))
                root.percentage = val;

        }
    }

    Process {
        id: setter
    }

    Process {
        id: stepper
    }

}
