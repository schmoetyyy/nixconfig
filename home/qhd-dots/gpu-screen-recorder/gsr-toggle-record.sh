#!/usr/bin/env bash
PIDFILE="$HOME/.cache/gsr-record.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -SIGINT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Recording" "Gestoppt & gespeichert"
else
    OUT="$HOME/Videos/Recording_$(date +%Y%m%d_%H%M%S).mp4"
    gpu-screen-recorder -w screen -f 60 -a default_output -c mp4 -o "$OUT" &
    echo $! > "$PIDFILE"
    notify-send "Recording" "Gestartet"
fi
