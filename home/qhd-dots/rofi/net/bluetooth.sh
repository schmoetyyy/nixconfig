#!/usr/bin/env bash

# Funktion für den Scan
do_scan() {
    notify-send "Bluetooth" "Searching for devices in Area..." -t 3000
    timeout 5 bluetoothctl scan on > /dev/null 2>&1
}

# Einmal kurz scannen beim ersten Start, damit nicht alles leer ist
timeout 2 bluetoothctl scan on > /dev/null 2>&1

# Endlosschleife, damit Rofi nach einem Rescan wieder aufpoppen kann
while true; do
    # 1. Bluetooth-Status prüfen
    BT_POWER=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    MENU=""

    if [ "$BT_POWER" = "yes" ]; then
        MENU+="󰂯  Deactivate Bluetooth\n"
        MENU+="󰂃  Open Blueman\n"
        MENU+="󰔄  Rescan for devices\n"

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

        # 3. Unbekannte Geräte (die schon im Speicher sind)
        ALL_DEVS=$(bluetoothctl devices)
        UNKNOWN_MENU=""
        while IFS= read -r line; do
            MAC=$(echo "$line" | awk '{print $2}')
            NAME=$(echo "$line" | cut -d' ' -f3-)
            IS_PAIRED=$(bluetoothctl info "$MAC" | grep "Paired:" | awk '{print $2}')
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

    # 5. Wenn nichts ausgewählt wurde (Escape), Skript komplett beenden
    [ -z "$SELECTED" ] && exit 0

    # 6. Auswertung der Auswahl
    CLEAN_TEXT=$(echo "$SELECTED" | sed 's/󰂯  //;s/󰂃  //;s/󰂱  //;s/󰂲  //;s/󰔄  //')
    TEXT=$(echo "$CLEAN_TEXT" | sed 's/ |.*//' | sed 's/ (active)//')
    MAC=$(echo "$CLEAN_TEXT" | grep -o '|.*' | tr -d '| ')

    # 7. Aktion ausführen
    if [ "$TEXT" = "Rescan for devices" ]; then
        # Scan durchführen und dann looped das Skript wieder nach oben zum Menü-Bauen
        do_scan
        continue
    elif [ "$TEXT" = "Deactivate Bluetooth" ]; then
        bluetoothctl power off
        notify-send "Bluetooth" "deactivated"
        exit 0
    elif [ "$TEXT" = "Activate Bluetooth" ]; then
        bluetoothctl power on
        notify-send "Bluetooth" "enabled"
        sleep 1
        continue
    elif [ "$TEXT" = "Open Blueman" ]; then
        blueman-manager &
        exit 0
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
        
        # Nachdem ein Gerät verbunden/getrennt wurde, Menü einmal aktualisieren
        sleep 1
        continue
    fi
done
