import QtQuick
import Quickshell.Io

// Servizio: interroga il sistema e basta, nessuna UI qui dentro.
// Chi lo usa (Dashboard.qml) fa solo binding sulle property.
Item {
    id: stats

    property real cpuUsage: 0        // 0..1
    property real ramUsage: 0        // 0..1
    property string ramLabel: "-- / -- GB"
    property real diskUsage: 0       // 0..1
    property string diskLabel: "-- / --"
    property real netRxKBs: 0
    property real netTxKBs: 0

    property var _prevCpu: null
    property var _prevNet: null
    property var _mem: ({})

    // --- CPU: delta tra due letture di /proc/stat ---
    Process {
        id: cpuReader
        command: ["sh", "-c", "head -n1 /proc/stat"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/).slice(1).map(Number);
                const idle = p[3] + p[4];
                const total = p.reduce((a, b) => a + b, 0);
                if (stats._prevCpu) {
                    const dIdle = idle - stats._prevCpu.idle;
                    const dTotal = total - stats._prevCpu.total;
                    if (dTotal > 0)
                        stats.cpuUsage = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
                }
                stats._prevCpu = { idle: idle, total: total };
            }
        }
    }

    // --- RAM ---
    Process {
        id: ramReader
        command: ["sh", "-c", "grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/(\w+):\s*(\d+)/);
                if (!m) return;
                stats._mem[m[1]] = parseInt(m[2], 10);
                if (stats._mem.MemTotal && stats._mem.MemAvailable) {
                    const totalGb = stats._mem.MemTotal / 1048576;
                    const usedGb = (stats._mem.MemTotal - stats._mem.MemAvailable) / 1048576;
                    stats.ramUsage = usedGb / totalGb;
                    stats.ramLabel = usedGb.toFixed(1) + " / " + totalGb.toFixed(1) + " GB";
                }
            }
        }
    }

    // --- Disco (filesystem radice) ---
    Process {
        id: diskReader
        command: ["sh", "-c", "df -h / | awk 'NR==2{gsub(\"%\",\"\",$5); print $2, $3, $5}'"]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(/\s+/);
                if (parts.length === 3) {
                    stats.diskLabel = parts[1] + " / " + parts[0];
                    stats.diskUsage = parseFloat(parts[2]) / 100;
                }
            }
        }
    }

    // --- Rete: somma di tutte le interfacce tranne lo ---
    Process {
        id: netReader
        command: ["sh", "-c",
            "awk 'NR>2 && $1 !~ /^lo:/ {gsub(\":\",\"\",$1); rx+=$2; tx+=$10} END {print rx, tx}' /proc/net/dev"]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(/\s+/).map(Number);
                if (parts.length < 2) return;
                const now = Date.now();
                if (stats._prevNet) {
                    const dt = (now - stats._prevNet.t) / 1000;
                    if (dt > 0) {
                        stats.netRxKBs = Math.max(0, (parts[0] - stats._prevNet.rx) / 1024 / dt);
                        stats.netTxKBs = Math.max(0, (parts[1] - stats._prevNet.tx) / 1024 / dt);
                    }
                }
                stats._prevNet = { rx: parts[0], tx: parts[1], t: now };
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.running = true;
            ramReader.running = true;
            diskReader.running = true;
            netReader.running = true;
        }
    }
}
