#!/usr/bin/env bash

# 1. Status des WLAN-Moduls prüfen
WIFI_STATUS=$(nmcli radio wifi)

# Wenn WLAN ausgeschaltet ist, bieten wir nur an, es einzuschalten
if [ "$WIFI_STATUS" = "disabled" ]; then
    SELECTED=$(echo -e "󰤭  Enable WLAN" | rofi -dmenu -i -p "WLAN ausgeschaltet:")
    if [ "$SELECTED" = "󰤭  Enable WLAN" ]; then
        nmcli radio wifi on
        notify-send "WLAN" "WLAN enabled"
    fi
    exit 0
fi

# 2. Ersten Menüpunkt bauen (Toggle WLAN an/aus)
MENU="󰤬  Disable WLAN\n"

# 3. Aktuell aktives WLAN herausfinden
ACTIVE_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d':' -f2)

# 4. Alle in der Umgebung verfügbaren WLANs scannen
# Wir sortieren und löschen doppelte Einträge (uniq) und leere Zeilen raus
AVAILABLE_WIFIS=$(nmcli -t -f SSID dev wifi list | grep -v '^--$' | grep -v '^$' | sort -u)

# 5. Menü für Rofi bauen
if [ -n "$AVAILABLE_WIFIS" ]; then
    while IFS= read -r wifi; do
        if [ "$wifi" = "$ACTIVE_SSID" ]; then
            MENU+="󰤨  ${wifi} (active)\n"
        else
            MENU+="󰤭  ${wifi}\n"
        fi
    done <<< "$AVAILABLE_WIFIS"
fi

# 6. Rofi öffnen und Auswahl speichern
# Das sed am Ende entfernt die Icons und den (aktiv) Tag wieder
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "WLAN:" | sed 's/󰤬  //;s/󰤭  //;s/󰤨  //;s/ (active)//')

# 7. Wenn nichts ausgewählt wurde (Escape), abbrechen
[ -z "$SELECTED" ] && exit 0

# 8. Aktion ausführen
if [ "$SELECTED" = "Disable WLAN" ]; then
    nmcli radio wifi off
    notify-send "WLAN" "Disable WLAN"
else
    # Versuchen, sich mit dem ausgewählten WLAN zu verbinden
    notify-send "WLAN" "Connecting with: $SELECTED..."
    nmcli device wifi connect "$SELECTED"
    
    # Prüfen, ob es geklappt hat
    if [ $? -eq 0 ]; then
        notify-send "WLAN" "Connected with: $SELECTED"
    else
        notify-send "WLAN" "Connection failed! (Password needed?)"
    fi
fi
