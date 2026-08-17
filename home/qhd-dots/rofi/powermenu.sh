#!/usr/bin/env bash

options="⏻  Shutdown\n  Reboot\n⏾  Sleep\n⏏  Logout\n󰔟  Time Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

case "$chosen" in
    "⏻  Shutdown")
        shutdown now
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "⏾  Sleep")
        systemctl suspend
        ;;
    "⏏  Logout")
        command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl     dispatch 'hl.dsp.exit()'
        ;;
    "󰔟  Time Shutdown")
        ~/nixconfig/home/qhd-dots/rofi/shutdown.sh
esac
