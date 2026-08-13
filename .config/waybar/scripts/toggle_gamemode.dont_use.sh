#!/usr/bin/env bash
$LUA_CONF="/home/giovanni/.config"
LOCK_FILE="${LUA_CONF}/hyde/gamemode.lck"

if [ -f "$LOCK_FILE" ]; then
    # Gamemode is ON → turn it OFF
    hyprctl reload config-only -q
    rm -f "$LOCK_FILE"
else
    # Gamemode is OFF → turn it ON
    mkdir -p "${LUA_CONF}/hyde"
    hyprctl keyword source "${LUA_CONF}/hypr/workflows/gaming.lua"
    touch "$LOCK_FILE"
fi
