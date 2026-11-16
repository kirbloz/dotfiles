#!/usr/bin/env bash
#
# setup-theming-configs.sh
#
# generate config files for
# GTK2, GTK3, GTK4,
# qt5ct, qt6ct
# from variables defined in theming.conf
#
# usage
#   ./setup.sh <path/to/theming.conf>
#

set -euo pipefail

# ---------------------------------------------------------------------------
# find theming.conf
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-${SCRIPT_DIR}/theming.conf}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo ">> can't find: ${CONFIG_FILE}" >&2
    echo ">> using: $0 [path/to/theming.conf]" >&2
    exit 1
fi

# shellcheck source=theming.conf
source "${CONFIG_FILE}"

# ---------------------------------------------------------------------------
# validation required vars
# ---------------------------------------------------------------------------
REQUIRED_VARS=(ICON_THEME CURSOR_THEME CURSOR_SIZE FONT_NAME FONT_SIZE)
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo ">> empty or missing '${var}' in ${CONFIG_FILE}" >&2
        exit 1
    fi
done
# GTK_THEME_NAME optional (can be left empty)
GTK_THEME_NAME="${GTK_THEME_NAME:-}"

# ---------------------------------------------------------------------------
# check cursor and icons themes exist in the system
# ---------------------------------------------------------------------------
check_theme_installed() {
    local theme_name="$1"
    local label="$2"
    if [[ ! -d "/usr/share/icons/${theme_name}" \
       && ! -d "${HOME}/.icons/${theme_name}" \
       && ! -d "${HOME}/.local/share/icons/${theme_name}" ]]; then
        echo ">> WARN: ${label} '${theme_name}' not in /usr/share/icons, ~/.icons or ~/.local/share/icons" >&2
    fi
}
check_theme_installed "${ICON_THEME}" "icon theme"
check_theme_installed "${CURSOR_THEME}" "cursor theme"

if [[ -n "${GTK_THEME_NAME}" && ! -d "/usr/share/themes/${GTK_THEME_NAME}" && ! -d "${HOME}/.themes/${GTK_THEME_NAME}" ]]; then
    echo "ATTENZIONE: GTK theme '${GTK_THEME_NAME}' non risulta installato in /usr/share/themes o ~/.themes." >&2
fi

# ---------------------------------------------------------------------------
# create target dirs
# ---------------------------------------------------------------------------
mkdir -p "${HOME}/.config/gtk-2.0"
mkdir -p "${HOME}/.config/gtk-3.0"
mkdir -p "${HOME}/.config/gtk-4.0"
mkdir -p "${HOME}/.config/qt5ct"
mkdir -p "${HOME}/.config/qt6ct"

# ---------------------------------------------------------------------------
# GTK2 -> ~/.config/gtk-2.0/gtkrc
# ---------------------------------------------------------------------------
{
    [[ -n "${GTK_THEME_NAME}" ]] && echo "gtk-theme-name=\"${GTK_THEME_NAME}\""
    echo "gtk-icon-theme-name=\"${ICON_THEME}\""
    echo "gtk-font-name=\"${FONT_NAME} ${FONT_SIZE}\""
    echo "gtk-cursor-theme-name=\"${CURSOR_THEME}\""
    echo "gtk-cursor-theme-size=${CURSOR_SIZE}"
    echo "gtk-xft-antialias=1"
    echo "gtk-xft-hinting=1"
    echo "gtk-xft-hintstyle=\"hintfull\""
    echo "gtk-xft-rgba=\"rgb\""
} > "${HOME}/.config/gtk-2.0/gtkrc"

# ---------------------------------------------------------------------------
# GTK3 -> ~/.config/gtk-3.0/settings.ini
# ---------------------------------------------------------------------------
{
    echo "[Settings]"
    [[ -n "${GTK_THEME_NAME}" ]] && echo "gtk-theme-name=${GTK_THEME_NAME}"
    echo "gtk-icon-theme-name=${ICON_THEME}"
    echo "gtk-font-name=${FONT_NAME} ${FONT_SIZE}"
    echo "gtk-cursor-theme-name=${CURSOR_THEME}"
    echo "gtk-cursor-theme-size=${CURSOR_SIZE}"
    echo "gtk-xft-antialias=1"
    echo "gtk-xft-hinting=1"
    echo "gtk-xft-hintstyle=hintfull"
    echo "gtk-xft-rgba=rgb"
    echo "gtk-application-prefer-dark-theme=1"
} > "${HOME}/.config/gtk-3.0/settings.ini"

# ---------------------------------------------------------------------------
# GTK4 -> ~/.config/gtk-4.0/settings.ini
# ---------------------------------------------------------------------------
cp "${HOME}/.config/gtk-3.0/settings.ini" "${HOME}/.config/gtk-4.0/settings.ini"

# ---------------------------------------------------------------------------
# qt5ct / qt6ct
# ---------------------------------------------------------------------------
{
    echo "[Appearance]"
    echo "icon_theme=${ICON_THEME}"
} > "${HOME}/.config/qt5ct/qt5ct.conf"

cp "${HOME}/.config/qt5ct/qt5ct.conf" "${HOME}/.config/qt6ct/qt6ct.conf"

# ---------------------------------------------------------------------------
# symlink GTK2 legacy (~/.gtkrc-2.0) if there isnt one already
# ---------------------------------------------------------------------------
if [[ -e "${HOME}/.gtkrc-2.0" || -L "${HOME}/.gtkrc-2.0" ]]; then
    echo ">> ~/.gtkrc-2.0 already exists - not touching it. check the file yourself" >&2
else
    ln -s "${HOME}/.config/gtk-2.0/gtkrc" "${HOME}/.gtkrc-2.0"
    echo ">> created symlink: ~/.gtkrc-2.0 -> ~/.config/gtk-2.0/gtkrc"
fi

# ---------------------------------------------------------------------------
# 10. Riepilogo
# ---------------------------------------------------------------------------
echo ""
echo ">> read configuration from: ${CONFIG_FILE}"
echo ">> wrote on these files:"
echo ">>   ~/.config/gtk-2.0/gtkrc"
echo ">>   ~/.config/gtk-3.0/settings.ini"
echo ">>   ~/.config/gtk-4.0/settings.ini"
echo ">>   ~/.config/qt5ct/qt5ct.conf"
echo ">>   ~/.config/qt6ct/qt6ct.conf"
if [[ -z "${GTK_THEME_NAME}" ]]; then
  echo "" 
  echo ">> NOTE: GTK_THEME_NAME is empty in theming.conf - 'gtk-theme-name' wasn't set"
fi

exit 1
