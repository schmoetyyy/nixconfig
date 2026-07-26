#!/usr/bin/env bash

# 1. Bluetooth-Status prüfen
BT_POWER=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
MENU=""

if [ "$BT_POWER" = "yes" ]; then
    MENU+="󰂯  Deactivate Bluetooth\n"
    MENU+="󰂃  Open Blueman\n"

    # 2. Bekannte (gepaarte) Geräte holen
    KNOWN_DEVS=$(bluetoothctl devices Paired)
    if [ -n "$KNOWN_DEVS" ]; then
        MENU+="\n--- Known Devices ---\n"
        while IFS= read -r line; do
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d' ' -f3-)
            IS_CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')
            if [ "$IS_CONNECTED" = "yes" ]; then
                MENU+="󰂱  $NAME (active) |$MAC\n"
            else
                MENU+="󰂲  $NAME |$MAC\n"
            fi
        done <<< "$KNOWN_DEVS"
    fi

    # 3. Unbekannte Geräte (Scannen)
    notify-send "Bluetooth" "Searching for devices in Area..." -t 3000
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
        MENU+="\n--- Unknown Devices ---\n"
        MENU+="$UNKNOWN_MENU"
    fi
else
    # Wenn Bluetooth ausgeschaltet ist
    MENU+="󰂯  Activate Bluetooth\n"
    MENU+="󰂃  Open Blueman\n"
fi

# 4. Rofi öffnen und Auswahl speichern
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "Bluetooth:")

# 5. Wenn nichts ausgewählt wurde (Escape), abbrechen
[ -z "$SELECTED" ] && exit 0

# 6. Auswertung der Auswahl
CLEAN_TEXT=$(echo "$SELECTED" | sed 's/󰂯  //;s/󰂃  //;s/󰂱  //;s/󰂲  //')
TEXT=$(echo "$CLEAN_TEXT" | sed 's/ |.*//' | sed 's/ (active)//')
MAC=$(echo "$CLEAN_TEXT" | grep -o '|.*' | tr -d '| ')

# 7. Aktion ausführen
if [ "$TEXT" = "Deactivate Bluetooth" ]; then
    bluetoothctl power off
    notify-send "Bluetooth" "deactivated"
elif [ "$TEXT" = "Activate Bluetooth" ]; then
    bluetoothctl power on
    notify-send "Bluetooth" "enabled"
elif [ "$TEXT" = "Open Blueman" ]; then
    blueman-manager &
elif [ -n "$MAC" ]; then
    IS_PAIRED=$(bluetoothctl info "$MAC" | grep "Paired:" | awk '{print $2}')
    IS_CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')

    if [ "$IS_PAIRED" = "no" ]; then
        notify-send "Bluetooth" "pairing $TEXT..."
        bluetoothctl pair "$MAC"
        bluetoothctl trust "$MAC"
        bluetoothctl connect "$MAC"
    elif [ "$IS_CONNECTED" = "yes" ]; then
        notify-send "Bluetooth" "disconnecting $TEXT..."
        bluetoothctl disconnect "$MAC"
    else
        notify-send "Bluetooth" "connecting $TEXT..."
        bluetoothctl connect "$MAC"
    fi
fi
