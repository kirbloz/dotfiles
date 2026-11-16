#!/usr/bin/env bash
#
# sysinfo.sh

# TODO REVIEW!
#
# Prints STATIC system info as key=value lines for SysInfoPageView.qml.
# Live stats (CPU/RAM/GPU/disk/network) come from the SystemStats singleton.
# Install to: ~/.config/neperozlinuz/scripts/sysinfo.sh
#
# Every value is single-line; missing data is simply left empty.

set -u

# --- OS / kernel / host -----------------------------------------------------
os="$( (. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Linux}") )"
kernel="$(uname -r)"
host="$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo unknown)"

# --- uptime -----------------------------------------------------------------
secs="$(cut -d. -f1 /proc/uptime 2>/dev/null || echo 0)"
d=$(( secs / 86400 )); h=$(( secs % 86400 / 3600 )); m=$(( secs % 3600 / 60 ))
if   (( d > 0 )); then uptime_str="${d}d ${h}h ${m}m"
elif (( h > 0 )); then uptime_str="${h}h ${m}m"
else                   uptime_str="${m}m"
fi

# --- CPU --------------------------------------------------------------------
cpu="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ *//')"
cores="$(nproc 2>/dev/null || echo 0)"

# --- GPU (needs pciutils; optional) ------------------------------------------
gpu=""
if command -v lspci >/dev/null 2>&1; then
    gpu="$(lspci -mm 2>/dev/null | awk -F'"' '/VGA|3D controller|Display controller/ { print $4 " " $6; exit }')"
fi

# --- session / packages / shell ---------------------------------------------
session="${XDG_CURRENT_DESKTOP:-unknown} (${XDG_SESSION_TYPE:-unknown})"
packages="$(pacman -Qq 2>/dev/null | wc -l)"
qs_version="$( (quickshell --version 2>/dev/null || qs --version 2>/dev/null) | head -n1 )"

cat <<EOF
os=${os}
kernel=${kernel}
host=${host}
uptime=${uptime_str}
cpu=${cpu}
cores=${cores}
gpu=${gpu}
session=${session}
packages=${packages}
shell=${qs_version}
EOF
