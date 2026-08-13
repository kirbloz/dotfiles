#!/bin/bash

# Script completo per notifiche multimediali e volume
# Uso: media-notify.sh {track|playpause|volume|mute}

NOTIFICATION_ID_FILE="/tmp/media_notify_id"
VOLUME_ID_FILE="/tmp/volume_notify_id"
LAST_TRACK_FILE="$HOME/.cache/last_track_notified"

# Funzione per notifica cambio traccia
notify_track() {
    local data status title artist album cover

    data=$(playerctl metadata --format $'{{status}}\x1f{{title}}\x1f{{artist}}\x1f{{album}}\x1f{{mpris:artUrl}}' 2>/dev/null)
    [ -z "$data" ] && exit 0

    IFS=$'\x1f' read -r status title artist album cover <<< "$data"
    cover="${cover#file://}"

    [ -z "$status" ] || [ -z "$title" ] && exit 0

    # Evita notifiche duplicate della stessa traccia
    current_track="$artist - $title"
    if [ -f "$LAST_TRACK_FILE" ]; then
        last_track=$(cat "$LAST_TRACK_FILE")
        [ "$current_track" = "$last_track" ] && exit 0
    fi
    echo "$current_track" > "$LAST_TRACK_FILE"

    if [ -n "$artist" ] && [ -n "$album" ]; then
        message="<b>$artist</b>\n󰀥 $album"
    elif [ -n "$artist" ]; then
        message="<b>$artist</b>"
    elif [ -n "$album" ]; then
        message="󰀥 $album"
    else
        message=""
    fi

    if [ "$status" = "Playing" ]; then
        icon_status=""
    else
        icon_status=""
    fi

    if [ -n "$cover" ] && [ -f "$cover" ]; then
        notify-send "$icon_status  $title" "$message" -i "$cover" -t 5000 -u normal \
            -h string:x-canonical-private-synchronous:music-track -c music
    else
        notify-send "$icon_status  $title" "$message" -i multimedia-player -t 5000 -u normal \
            -h string:x-canonical-private-synchronous:music-track -c music
    fi
}

# Funzione per notifica play/pause
notify_playpause() {
    status=$(playerctl status 2>/dev/null)
    [ -z "$status" ] && exit 0

    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    
    if [ "$status" = "Playing" ]; then
        icon=""
        message="In riproduzione"
    else
        icon=""
        message="In pausa"
    fi

    # Mostra artista se disponibile
    body="$title"
    [ -n "$artist" ] && body="$body\n<i>$artist</i>"

    notify-send "$icon $message" "$body" \
        -i multimedia-player \
        -t 2000 \
        -h string:x-canonical-private-synchronous:media \
        -c music
}

# Funzione per notifica volume
notify_volume() {
    # Ottieni volume e stato mute
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED)

    # Determina icona
    if [ -n "$muted" ]; then
        icon="󰖁"
        status="Mutato"
        bar=""
    else
        if [ "$volume" -ge 70 ]; then
            icon="󰕾"
        elif [ "$volume" -ge 30 ]; then
            icon="󰖀"
        elif [ "$volume" -gt 0 ]; then
            icon="󰕿"
        else
            icon="󰖁"
        fi
        status="Volume"
        
        # Crea barra progressiva
        filled=$((volume / 5))
        empty=$((20 - filled))
        bar=$(printf '█%.0s' $(seq 1 $filled))
        bar="$bar$(printf '░%.0s' $(seq 1 $empty))"
    fi

    # Notifica con hint per sostituire la precedente
    notify-send "$icon $status" "$bar ${volume}%" \
        -t 2000 \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:"$volume"
}

# Funzione per toggle mute
notify_mute() {
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED)
    
    if [ -n "$muted" ]; then
        icon="󰖁"
        message="Audio Mutato"
    else
        icon="󰕾"
        message="Audio Attivo"
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        message="$message - ${volume}%"
    fi

    notify-send "$icon $message" "" \
        -t 2000 -h string:x-canonical-private-synchronous:volume
}

# Funzione per notifica luminosità (bonus)
notify_brightness() {
    brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((brightness * 100 / max_brightness))
    
    if [ "$percentage" -ge 70 ]; then
        icon="󰃠"
    elif [ "$percentage" -ge 30 ]; then
        icon="󰃟"
    else
        icon="󰃞"
    fi
    
    # Barra progressiva
    filled=$((percentage / 5))
    empty=$((20 - filled))
    bar=$(printf '█%.0s' $(seq 1 $filled))
    bar="$bar$(printf '░%.0s' $(seq 1 $empty))"
    
    notify-send "$icon Luminosità" "$bar ${percentage}%" \
        -t 2000 -h string:x-canonical-private-synchronous:brightness \
        -h int:value:"$percentage"
}

# Main
case "$1" in
    track)
        notify_track
        ;;
    playpause)
        notify_playpause
        ;;
    volume)
        notify_volume
        ;;
    mute)
        notify_mute
        ;;
    brightness)
        notify_brightness
        ;;
    *)
        echo "Uso: $0 {track|playpause|volume|mute|brightness}"
        exit 1
        ;;
esac


# watcher che innesca la track
#
# #!/bin/bash
# ~/.local/bin/track-watcher.sh
#exec playerctl --follow status 2>/dev/null | while read -r status; do
#    [ "$status" = "Playing" ] && "$HOME/.local/bin/media-notify.sh" track
#done

# servizio per il watcher
# ~/.config/systemd/user/track-watcher.service
#[Unit]
#Description=Watch playback and notify on new track
#After=graphical-session.target
#
#[Service]
#ExecStart=%h/.local/bin/track-watcher.sh
#Restart=on-failure
#RestartSec=2
#
#[Install]
#WantedBy=default.target