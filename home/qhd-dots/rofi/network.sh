#!/usr/bin/env bash

options="⏻  Toggle Network\n󰌗  Networking\n  Wifi\n󰂯  Bluetooth\n  Vpn\n  Network Manager"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

case "$chosen" in
    "⏻  Toggle Network")
        bash -c '[ "$(nmcli networking)" = "enabled" ] && nmcli networking off || nmcli networking on'
        ;;
    "󰌗  Networking")
        ~/nixconfig/home/qhd-dots/rofi/net/networking.sh
        ;;
    "  Wifi")
        ~/nixconfig/home/qhd-dots/rofi/net/wifi.sh
        ;;
    "󰂯  Bluetooth")
        ~/nixconfig/home/qhd-dots/rofi/net/bluetooth.sh
        ;;
    "  Vpn")
        ~/nixconfig/home/qhd-dots/rofi/net/vpn.sh
        ;;
    "  Network Manager")
        nm-connection-editor
esac
