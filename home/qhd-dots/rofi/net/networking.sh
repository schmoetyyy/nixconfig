#!/usr/bin/env bash

# 1. LAN-Gerät (Interface) finden, z.B. eth0 oder enp3s0
# (Wir suchen nach dem ersten Ethernet-Gerät, das nicht "unmanaged" ist)
ETH_DEV=$(nmcli -t -f DEVICE,TYPE,STATE dev status | grep ':ethernet:' | grep -v ':unmanaged$' | cut -d':' -f1 | head -n1)

MENU=""

# 2. Ersten Menüpunkt bauen (Toggle LAN an/aus)
if [ -n "$ETH_DEV" ]; then
    # Status des Geräts prüfen
    ETH_STATE=$(nmcli -t -f DEVICE,STATE dev status | grep "^${ETH_DEV}:" | cut -d':' -f2)
    
    if [ "$ETH_STATE" = "connected" ]; then
        MENU="󰈁  Disable LAN (${ETH_DEV})\n"
    else
        MENU="󰈀  Enable LAN (${ETH_DEV})\n"
    fi
else
    MENU="⚠ No LAN-adapter found\n"
fi

# 3. Alle gespeicherten LAN-Verbindungen (Profile) holen
ALL_LANS=$(nmcli -t -f NAME,TYPE connection | grep ':ethernet$' | cut -d':' -f1)

# 4. Alle aktuell AKTIVEN LAN-Verbindungen holen
ACTIVE_LANS=$(nmcli -t -f NAME,TYPE,ACTIVE connection show --active | grep ':ethernet:yes$' | cut -d':' -f1)

# 5. Restliches Menü für Rofi bauen
if [ -n "$ALL_LANS" ]; then
    while IFS= read -r lan; do
        if echo "$ACTIVE_LANS" | grep -q "^${lan}$"; then
            MENU+="󰈀  ${lan} (active)\n"
        else
            MENU+="󰈁  ${lan}\n"
        fi
    done <<< "$ALL_LANS"
fi

# 6. Rofi öffnen und Auswahl speichern
# Das sed am Ende entfernt die Icons und die Klammern/Tags wieder
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "LAN:" | sed 's/󰈁  //;s/󰈀  //;s/ (active)//;s/ (.*//')

# 7. Wenn nichts ausgewählt wurde (Escape), abbrechen
[ -z "$SELECTED" ] && exit 0

# 8. Aktion ausführen
if echo "$SELECTED" | grep -q "Disable LAN"; then
    nmcli dev disconnect "$ETH_DEV"
    notify-send "LAN" "LAN disabled ($ETH_DEV)"
elif echo "$SELECTED" | grep -q "Enable LAN"; then
    nmcli dev connect "$ETH_DEV"
    notify-send "LAN" "LAN enabled ($ETH_DEV)"
elif [ "$SELECTED" = "⚠ No LAN-adapter found" ]; then
    exit 0
else
    # Ein bestimmtes Profil toggeln
    if echo "$ACTIVE_LANS" | grep -q "^${SELECTED}$"; then
        nmcli connection down "$SELECTED"
        notify-send "LAN" "Disconnected from: $SELECTED"
    else
        nmcli connection up "$SELECTED"
        notify-send "LAN" "Connected with: $SELECTED"
    fi
fi
