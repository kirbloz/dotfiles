#!/bin/bash
# Interactive brightness control menu - Controls ALL monitors

clear

declare -A DISPLAY_MAP=(
  ["card1-HDMI-A-1"]="1"
)

# Get all monitor brightnesses
get_all_brightness() {
    local -A brightnesses
    while IFS=: read -r monitor value; do
        monitor=$(echo "$monitor" | xargs)
        value=$(echo "$value" | grep -oP '\d+' || echo "50")
        brightnesses["$monitor"]="$value"
    done < <(~/bin/brightness status 2>/dev/null | grep -E "HDMI-")

    # Return average for display
    local total=0
    local count=0
    for mon in "${!brightnesses[@]}"; do
        total=$((total + brightnesses[$mon]))
        count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
        echo $((total / count))
    else
        echo 50
    fi
}

# Color codes
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
RESET='\033[0m'

# Draw a visual brightness bar
draw_bar() {
    local value=$1
    local width=50
    local filled=$((value * width / 100))
    local empty=$((width - filled))

    echo -n "["
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo "]"
}

# Main menu
while true; do
    clear
    CURRENT=$(get_all_brightness)

    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║       Multi-Monitor Brightness Control        ║${RESET}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════╝${RESET}\n"

    echo -e "${MAGENTA}${BOLD}📺 Controlling: ALL MONITORS${RESET}"
    echo -e "Average brightness: ${YELLOW}${CURRENT}%${RESET}\n"

    draw_bar "$CURRENT"
    echo ""

    # Show individual monitor status
    echo -e "\n${BOLD}Individual Status:${RESET}"
    ~/bin/brightness status | grep -E "HDMI-" | while IFS=: read -r mon val; do
        echo -e "  ${GREEN}${mon}${RESET}: ${val}"
    done

    echo -e "\n${BOLD}Quick Presets (ALL monitors):${RESET}"
    echo "  [1] 0%   (Off)"
    echo "  [2] 25%  (Low)"
    echo "  [3] 50%  (Medium)"
    echo "  [4] 75%  (High)"
    echo "  [5] 100% (Maximum)"

    echo -e "\n${BOLD}Adjustments (ALL monitors):${RESET}"
    echo "  [+] Increase by 10%"
    echo "  [-] Decrease by 10%"
    echo "  [c] Custom value (0-100)"

    echo -e "\n${BOLD}Other:${RESET}"
    echo "  [r] Refresh status"
    echo "  [q] Quit"

    echo -ne "\n${BOLD}${CYAN}Choose an option:${RESET} "
    read -n 1 choice
    echo ""

    case "$choice" in
        1)
            ~/bin/brightness set-all 0 >/dev/null 2>&1
            ;;
        2)
            ~/bin/brightness set-all 25 >/dev/null 2>&1
            ;;
        3)
            ~/bin/brightness set-all 50 >/dev/null 2>&1
            ;;
        4)
            ~/bin/brightness set-all 75 >/dev/null 2>&1
            ;;
        5)
            ~/bin/brightness set-all 100 >/dev/null 2>&1
            ;;
        +|=)
            ~/bin/brightness up-all >/dev/null 2>&1
            ;;
        -)
            ~/bin/brightness down-all >/dev/null 2>&1
            ;;
        c|C)
            echo -ne "\n${CYAN}Enter brightness value (0-100) for ALL monitors:${RESET} "
            read -r custom_value
            if [[ "$custom_value" =~ ^[0-9]+$ ]] && [[ $custom_value -ge 0 ]] && [[ $custom_value -le 100 ]]; then
                ~/bin/brightness set-all "$custom_value" >/dev/null 2>&1
            else
                echo -e "${YELLOW}Invalid value. Press Enter to continue...${RESET}"
                read
            fi
            ;;
        r|R)
            # Just refresh by looping
            ;;
        q|Q)
            clear
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Press Enter to continue...${RESET}"
            read
            ;;
    esac

    # Small delay to show the change
    sleep 0.3
done
