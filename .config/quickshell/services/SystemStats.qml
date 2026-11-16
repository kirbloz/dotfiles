pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

/*! 
    \qmltype SystemStats
    \inqmlmodule services
    \inherits Singleton
    \brief this service collects data about the system; components that use it access its properties and handle all view logic
*/

Singleton {
    //property var _mem: ({})
    // --- gpu & vram ---

    id: stats

    property real cpuUsage: 0 // 0..1
    property real gpuUsage: 0 // 0..1
    property real ramUsage: 0 // 0..1
    property real vramUsage: 0 // 0..1
    // tags
    property string ramLabel: "-- / -- GB"
    property string vramLabel: "-- / -- GB"
    property real diskUsage: 0 // 0..1
    property string diskLabel: "-- / --"
    // network
    property real netRxKBs: 0
    property real netTxKBs: 0
    readonly property string netRxFormatted: formatSpeed(netRxKBs)
    readonly property string netTxFormatted: formatSpeed(netTxKBs)
    property var _prevCpu: null
    property var _prevNet: null
    property string _gpuVendor: "auto" // auto, amd, intel, nvidia, none
    readonly property bool isPopupOpen: Boolean(PopupService.dashboardPopup?.isOpen)

    function formatSpeed(kbs) {
        if (kbs >= 1024)
            return (kbs / 1024).toFixed(1) + " MB/s";

        return Math.round(kbs) + " KB/s";
    }

    // /proc/stat, /proc/meminfo e /proc/net/dev
    Process {
        id: coreReader

        command: ["sh", "-c", "head -n1 /proc/stat; " + "grep -E 'MemTotal|MemAvailable' /proc/meminfo; " + "awk 'NR>2 && $1 !~ /^lo:/ {rx+=$2; tx+=$10} END {print rx, tx}' /proc/net/dev"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 3)
                    return ;

                // --- CPU ---
                const cpuParts = lines[0].trim().split(/\s+/).slice(1).map(Number);
                if (cpuParts.length >= 4) {
                    const idle = cpuParts[3] + (cpuParts[4] || 0);
                    const total = cpuParts.reduce((a, b) => {
                        return a + b;
                    }, 0);
                    if (stats._prevCpu) {
                        const dIdle = idle - stats._prevCpu.idle;
                        const dTotal = total - stats._prevCpu.total;
                        if (dTotal > 0)
                            stats.cpuUsage = Math.max(0, Math.min(1, 1 - (dIdle / dTotal)));

                    }
                    stats._prevCpu = {
                        "idle": idle,
                        "total": total
                    };
                }
                // --- RAM ---
                let memTotal = 0;
                let memAvailable = 0;
                for (let i = 1; i < lines.length - 1; i++) {
                    const m = lines[i].match(/(\w+):\s*(\d+)/);
                    if (m) {
                        if (m[1] === "MemTotal")
                            memTotal = parseInt(m[2], 10);

                        if (m[1] === "MemAvailable")
                            memAvailable = parseInt(m[2], 10);

                    }
                }
                if (memTotal > 0 && memAvailable > 0) {
                    const totalGb = memTotal / 1.04858e+06;
                    const usedGb = (memTotal - memAvailable) / 1.04858e+06;
                    stats.ramUsage = Math.max(0, Math.min(1, usedGb / totalGb));
                    stats.ramLabel = usedGb.toFixed(1) + " / " + totalGb.toFixed(1) + " GB";
                }
                // --- NET ---
                const netParts = lines[lines.length - 1].trim().split(/\s+/).map(Number);
                if (netParts.length >= 2) {
                    const now = Date.now();
                    if (stats._prevNet) {
                        const dt = (now - stats._prevNet.t) / 1000;
                        if (dt > 0) {
                            stats.netRxKBs = Math.max(0, (netParts[0] - stats._prevNet.rx) / 1024 / dt);
                            stats.netTxKBs = Math.max(0, (netParts[1] - stats._prevNet.tx) / 1024 / dt);
                        }
                    }
                    stats._prevNet = {
                        "rx": netParts[0],
                        "tx": netParts[1],
                        "t": now
                    };
                }
            }
        }

    }

    // --- disk ---
    Process {
        id: diskReader

        command: ["sh", "-c", 'df -h "$HOME" | awk \'NR==2{gsub("%","",$5); print $2, $3, $5}\'']

        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(/\s+/);
                if (parts.length === 3) {
                    stats.diskLabel = parts[1] + " / " + parts[0];
                    stats.diskUsage = Math.max(0, Math.min(1, parseFloat(parts[2]) / 100));
                }
            }
        }

    }

    Process {
        // AMD GPU via sysfs
        // Intel GPU (engine busy or freq)
        // NVIDIA via nvidia-smi

        id: gpuReader

        // tries AMD (gpu_busy_percent), Intel (i915/xe), Nvidia via nvidia-smi
        command: ["sh", "-c", "if [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then " + "  busy=$(cat /sys/class/drm/card0/device/gpu_busy_percent); " + "  vused=$(cat /sys/class/drm/card0/device/mem_info_vram_used 2>/dev/null || echo 0); " + "  vtotal=$(cat /sys/class/drm/card0/device/mem_info_vram_total 2>/dev/null || echo 0); " + "  echo \"AMD $busy $vused $vtotal\"; " + "elif [ -d /sys/class/drm/card0/gt_act_freq_mhz ]; then " + "  cur=$(cat /sys/class/drm/card0/gt_act_freq_mhz); " + "  max=$(cat /sys/class/drm/card0/gt_max_freq_mhz); " + "  echo \"INTEL $cur $max\"; " + "elif command -v nvidia-smi >/dev/null 2>&1; then " + "  nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | head -n1; " + "else echo \"NONE\"; fi"]

        stdout: SplitParser {
            onRead: (line) => {
                const trimmed = line.trim();
                if (trimmed === "NONE" || trimmed === "")
                    return ;

                if (trimmed.startsWith("AMD")) {
                    const p = trimmed.split(/\s+/);
                    stats.gpuUsage = Math.max(0, Math.min(1, (parseInt(p[1], 10) || 0) / 100));
                    const vUsed = parseInt(p[2], 10) || 0;
                    const vTotal = parseInt(p[3], 10) || 0;
                    if (vTotal > 0) {
                        stats.vramUsage = vUsed / vTotal;
                        stats.vramLabel = (vUsed / 1.07374e+09).toFixed(1) + " / " + (vTotal / 1.07374e+09).toFixed(1) + " GB";
                    }
                } else if (trimmed.startsWith("INTEL")) {
                    const p = trimmed.split(/\s+/);
                    const cur = parseInt(p[1], 10) || 0;
                    const max = parseInt(p[2], 10) || 1;
                    stats.gpuUsage = Math.max(0, Math.min(1, cur / max));
                } else if (trimmed.includes(",")) {
                    // NVIDIA (output: "usage, used, total")
                    const p = trimmed.split(",").map((s) => {
                        return parseInt(s.trim(), 10);
                    });
                    if (p.length >= 3) {
                        stats.gpuUsage = Math.max(0, Math.min(1, p[0] / 100));
                        stats.vramUsage = Math.max(0, Math.min(1, p[1] / p[2]));
                        stats.vramLabel = (p[1] / 1024).toFixed(1) + " / " + (p[2] / 1024).toFixed(1) + " GB";
                    }
                }
            }
        }

    }

    // --- net ---
    Process {
        id: netReader

        command: ["sh", "-c", "awk 'NR>2 && $1 !~ /^lo:/ {gsub(\":\",\"\",$1); rx+=$2; tx+=$10} END {print rx, tx}' /proc/net/dev"]

        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(/\s+/).map(Number);
                if (parts.length < 2)
                    return ;

                const now = Date.now();
                if (stats._prevNet) {
                    const dt = (now - stats._prevNet.t) / 1000;
                    if (dt > 0) {
                        stats.netRxKBs = Math.max(0, (parts[0] - stats._prevNet.rx) / 1024 / dt);
                        stats.netTxKBs = Math.max(0, (parts[1] - stats._prevNet.tx) / 1024 / dt);
                    }
                }
                stats._prevNet = {
                    "rx": parts[0],
                    "tx": parts[1],
                    "t": now
                };
            }
        }

    }

    Timer {
        interval: 2000
        running: isPopupOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!coreReader.running)
                coreReader.running = true;

            if (!gpuReader.running)
                gpuReader.running = true;

        }
    }

    // disk changes less frequently
    Timer {
        interval: 100000
        running: isPopupOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!diskReader.running)
                diskReader.running = true;

        }
    }

}
