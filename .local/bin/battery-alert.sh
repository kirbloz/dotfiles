#!/bin/sh
# ~/.local/bin/battery-alert.sh
export PATH=/home/giovanni/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

bat=$(find /sys/class/power_supply -maxdepth 1 -iname 'BAT*' | head -n1)
[ -z "$bat" ] && exit 0

BATTERY_LEVEL=$(cat "$bat/capacity")
BATTERY_STATUS=$(cat "$bat/status")

WARNING_LEVEL=20
CRITICAL_LEVEL=5

FULL_FILE=/tmp/batteryfull
EMPTY_FILE=/tmp/batteryempty
CRITICAL_FILE=/tmp/batterycritical

if [ "$BATTERY_STATUS" = "Discharging" ] && [ -f "$FULL_FILE" ]; then
    rm -f "$FULL_FILE"
elif [ "$BATTERY_STATUS" = "Charging" ] && [ -f "$EMPTY_FILE" ]; then
    rm -f "$EMPTY_FILE" "$CRITICAL_FILE"
fi

if [ "$BATTERY_LEVEL" -gt 91 ] && [ "$BATTERY_STATUS" = "Charging" ] && [ ! -f "$FULL_FILE" ]; then
    notify-send "Battery Charged" "Battery is fully charged." -r 9991
    touch "$FULL_FILE"
elif [ "$BATTERY_LEVEL" -le "$WARNING_LEVEL" ] && [ "$BATTERY_STATUS" = "Discharging" ] && [ ! -f "$EMPTY_FILE" ]; then
    notify-send "Low Battery" "${BATTERY_LEVEL}% of battery remaining." -u critical -r 9991
    touch "$EMPTY_FILE"
elif [ "$BATTERY_LEVEL" -le "$CRITICAL_LEVEL" ] && [ "$BATTERY_STATUS" = "Discharging" ] && [ ! -f "$CRITICAL_FILE" ]; then
    notify-send "Battery Critical" "The computer will shutdown soon." -u critical -r 9991
    touch "$CRITICAL_FILE"
fi

# ~/.config/systemd/user/battery-alert.service
#[Unit]
#Description=Battery alert check
#
#[Service]
#Type=oneshot
#ExecStart=/home/giovanni/.local/bin/battery-alert.sh


#~/.config/systemd/user/battery-alert.timer
#[Unit]
#Description=Run battery alert check periodically
#
#[Timer]
#OnBootSec=30
#OnUnitActiveSec=60
#Unit=battery-alert.service
#
#[Install]
#WantedBy=timers.target