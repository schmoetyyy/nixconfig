#!/usr/bin/env bash

# Aktive VPN-Verbindung suchen
vpn=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="vpn"{print $1}' | head -n1)

if [ -n "$vpn" ]; then
    text=" $vpn"
    tooltip="VPN aktiv: $vpn"
    class="vpn"
else
    # normale Verbindung (WLAN/Ethernet)
    con=$(nmcli -t -f NAME,TYPE connection show --active | grep -v ':vpn$' | head -n1)
    name=$(cut -d: -f1 <<< "$con")
    type=$(cut -d: -f2 <<< "$con")

    if [ "$type" = "802-11-wireless" ]; then
        icon=""
    elif [ "$type" = "802-3-ethernet" ]; then
        icon="󰈀"
    else
        icon="󰤭"
        name="Getrennt"
    fi

    text=" $icon "
    tooltip="$name"
    class="connected"
fi

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
