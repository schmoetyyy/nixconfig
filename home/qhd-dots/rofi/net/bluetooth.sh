#!/usr/bin/env bash

# 1. Bluetooth-Status prüfen
BT_POWER=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
MENU=""

if [ "$BT_POWER" = "yes" ]; then
    MENU+="󰂯  Bluetooth Ausschalten\n"
    MENU+="󰂃  Blueman öffnen\n"

    # 2. Bekannte (gepaarte) Geräte holen
    KNOWN_DEVS=$(bluetoothctl devices Paired)
    if [ -n "$KNOWN_DEVS" ]; then
        MENU+="\n--- Bekannte Geräte ---\n"
        while IFS= read -r line; do
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d' ' -f3-)
            IS_CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')
            if [ "$IS_CONNECTED" = "yes" ]; then
                MENU+="󰂱  $NAME (aktiv) |$MAC\n"
            else
                MENU+="󰂲  $NAME |$MAC\n"
            fi
        done <<< "$KNOWN_DEVS"
    fi

    # 3. Unbekannte Geräte (Scannen)
    notify-send "Bluetooth" "Suche nach neuen Geräten in der Umgebung..." -t 3000
    # 4 Sekunden scannen
    timeout 4 bluetoothctl scan on > /dev/null 2>&1
    
    ALL_DEVS=$(bluetoothctl devices)
    UNKNOWN_MENU=""
    while IFS= read -r line; do
        MAC=$(echo "$line" | awk '{print $2}')
        NAME=$(echo "$line" | cut -d' ' -f3-)
        IS_PAIRED=$(bluetoothctl info "$MAC" | grep "Paired:" | awk '{print $2}')
        # Wenn es nicht gepaart ist, ist es unbekannt
        if [ "$IS_PAIRED" = "no" ]; then
            UNKNOWN_MENU+="󰂲  $NAME |$MAC\n"
        fi
    done <<< "$ALL_DEVS"

    if [ -n "$UNKNOWN_MENU" ]; then
        MENU+="\n--- Unbekannte Geräte ---\n"
        MENU+="$UNKNOWN_MENU"
    fi

else
    # Wenn Bluetooth ausgeschaltet ist
    MENU+="󰂯  Bluetooth Einschalten\n"
    MENU+="󰂃  Blueman öffnen\n"
fi

# 4. Rofi öffnen und Auswahl speichern
# Wir packen die MAC-Adresse unsichtbar hinten dran (hinter dem |), damit das Skript sie nutzen kann
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "Bluetooth:")

# 5. Wenn nichts ausgewählt wurde (Escape), abbrechen
[ -z "$SELECTED" ] && exit 0

# 6. Auswertung der Auswahl
# Icons am Anfang entfernen
CLEAN_TEXT=$(echo "$SELECTED" | sed 's/󰂯  //;s/󰂃  //;s/󰂱  //;s/󰂲  //')
# Text und MAC-Adresse trennen (MAC steht nach dem | )
TEXT=$(echo "$CLEAN_TEXT" | sed 's/ |.*//' | sed 's/ (aktiv)//')
MAC=$(echo "$CLEAN_TEXT" | grep -o '|.*' | tr -d '| ')

# 7. Aktion ausführen
if [ "$TEXT" = "Bluetooth Ausschalten" ]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Ausgeschaltet"
elif [ "$TEXT" = "Bluetooth Einschalten" ]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Eingeschaltet"
elif [ "$TEXT" = "Blueman öffnen" ]; then
    blueman-manager &
elif [ -n "$MAC" ]; then
    # Es ist ein Gerät (wir haben die MAC-Adresse)
    IS_PAIRED=$(bluetoothctl info "$MAC" | grep "Paired:" | awk '{print $2}')
    IS_CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')

    if [ "$IS_PAIRED" = "no" ]; then
        # Unbekanntes Gerät: Koppeln und verbinden
        notify-send "Bluetooth" "Kopple $TEXT..."
        bluetoothctl pair "$MAC"
        bluetoothctl trust "$MAC"
        bluetoothctl connect "$MAC"
    elif [ "$IS_CONNECTED" = "yes" ]; then
        # Bekanntes Gerät, aktiv -> Trennen
        notify-send "Bluetooth" "Trenne $TEXT..."
        bluetoothctl disconnect "$MAC"
    else
        # Bekanntes Gerät, inaktiv -> Verbinden
        notify-send "Bluetooth" "Verbinde $TEXT..."
        bluetoothctl connect "$MAC"
    fi
fi
