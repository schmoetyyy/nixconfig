#!/usr/bin/env bash

options="  10min\n  30min\n  1h\n  2h\n  3h\n  4h"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

case "$chosen" in
    "  10min")
        shutdown +10
        ;;
    "  30min")
        shutdown +30
        ;;
    "  1h")
        shutdown +60
        ;;
    "  2h")
        shutdown +120
        ;;
    "  3h")
        shutdown +180
        ;;
    "  4h")
        shutdown +240
        ;;
esac
