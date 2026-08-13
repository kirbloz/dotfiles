#!/bin/bash
# ~/.local/bin/music-notify.sh
# Notifica desktop ogni volta che parte un nuovo brano

download_album_art=true
notification_timeout=4000
last_track=""

get_album_art() {
    url=$(playerctl -f "{{mpris:artUrl}}" metadata 2>/dev/null)
    if [[ $url == file://* ]]; then
        album_art="${url/file:\/\//}"
    elif [[ $url == http*://* ]] && [[ $download_album_art == "true" ]]; then
        filename="$(basename "$url")"
        [ ! -f "/tmp/$filename" ] && wget -q -O "/tmp/$filename" "$url"
        album_art="/tmp/$filename"
    else
        album_art=""
    fi
}

playerctl --follow status 2>/dev/null | while read -r status; do
    [ "$status" != "Playing" ] && continue

    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    track_id="$title|$artist"

    # evita di ri-notificare lo stesso brano su pausa/ripresa
    [ "$track_id" = "$last_track" ] && continue
    last_track="$track_id"

    get_album_art
    notify-send -t "$notification_timeout" -h string:x-dunst-stack-tag:music_notif -i "$album_art" "$title" "$artist"
done