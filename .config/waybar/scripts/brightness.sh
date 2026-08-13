#!/bin/bash
# Waybar brightness indicator for DDC monitors - Shows average across all monitors

STATE_DIR="/run/user/$(id -u)/brightness"

declare -A DISPLAY_MAP=(
  ["card1-HDMI-A-1"]="1"
)
# Get average brightness from all monitors
get_average_brightness() {
    local total=0
    local count=0
    local -A monitors=(["card1-HDMI-A-1"]="1")

    for monitor in "${!monitors[@]}"; do
        local state_file="$STATE_DIR/${monitor}.state"

        if [[ -f "$state_file" ]]; then
            # Use cached state if recent
            local state_age=$(( $(date +%s) - $(stat -c %Y "$state_file" 2>/dev/null || echo 0) ))
            if [[ $state_age -lt 3 ]]; then
                local val=$(cat "$state_file")
                total=$((total + val))
                count=$((count + 1))
            fi
        fi
    done

    # If no cached data, query from hardware
    if [[ $count -eq 0 ]]; then
        while IFS=: read -r mon val; do
            val=$(echo "$val" | grep -oP '\d+' || echo "0")
            if [[ $val -gt 0 ]]; then
                total=$((total + val))
                count=$((count + 1))
            fi
        done < <(~/bin/brightness status 2>/dev/null | grep -E "DP-")
    fi

    if [[ $count -gt 0 ]]; then
        echo $((total / count))
    else
        echo 50
    fi
}

BRIGHTNESS=$(get_average_brightness)

# Choose icon based on brightness level
if [[ $BRIGHTNESS -ge 80 ]]; then
    ICON=$'\uf185 '  # nf-fa-sun_o
elif [[ $BRIGHTNESS -ge 40 ]]; then
    ICON=$'\uf042 '  # nf-fa-adjust 
elif [[ $BRIGHTNESS -gt 0 ]]; then
    ICON=$'\uf042 '  # nf-fa-adjust
else
    ICON=$'\uf186 '  # nf-fa-moon_o 
fi

# Build tooltip with helpful info
TOOLTIP="💡 Average Brightness: ${BRIGHTNESS}%\n"
TOOLTIP+="📺 Controls: ALL MONITORS\n\n"
TOOLTIP+="🖱️ Scroll to adjust all (±10%)\n"
TOOLTIP+="🖱️ Click for detailed menu"

# Output JSON for Waybar
echo "{\"icon\":\"${ICON}\", \"tooltip\":\"${TOOLTIP}\",\"class\":\"brightness\",\"percentage\":${BRIGHTNESS}}"
