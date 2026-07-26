#!/usr/bin/env bash

# 1. Hole alle VPN- und Wireguard-Verbindungen
ALL_VPNS=$(nmcli -t -f NAME,TYPE connection | grep -E ':(vpn|wireguard)$' | cut -d':' -f1)


# 2. Hole alle aktuell AKTIVEN VPNs
ACTIVE_VPNS=$(nmcli -t -f NAME,TYPE,ACTIVE connection show --active | grep -E ':(vpn|wireguard):yes$' | cut -d':' -f1)

# 3. Menü für Rofi bauen (aktive bekommen ein Symbol davor)
MENU=""
while IFS= read -r vpn; do
    if echo "$ACTIVE_VPNS" | grep -q "^${vpn}$"; then
        MENU+="󰤨  ${vpn} (active)\n"
    else
        MENU+="󰤭  ${vpn}\n"
    fi
done <<< "$ALL_VPNS"

# 4. Rofi öffnen und Auswahl speichern
# sed am Ende entfernt das Icon und "(aktiv)" wieder aus der Auswahl, 
# damit nmcli den echten Namen bekommt
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "toggle VPN:" | sed 's/󰤨  //;s/󰤭  //;s/ (active)//')

# 5. Wenn nichts ausgewählt wurde (Escape), abbrechen
[ -z "$SELECTED" ] && exit 0

# 6. Prüfen, ob die Auswahl aktiv ist -> toggeln
if echo "$ACTIVE_VPNS" | grep -q "^${SELECTED}$"; then
    nmcli connection down "$SELECTED"
    notify-send "VPN" "deactivated: $SELECTED"
else
    nmcli connection up "$SELECTED"
    notify-send "VPN" "connected with: $SELECTED"
fi
