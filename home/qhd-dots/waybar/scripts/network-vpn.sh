#!/usr/bin/env bash

# 1. Internet-Verbindung prüfen (full = Internet vorhanden)
CONNECTIVITY=$(nmcli -g connectivity general)

# 2. Alle aktiven VPNs holen und durch Komma trennen
# paste -sd "," - macht aus mehreren Zeilen eine einzige Zeile, getrennt durch Komma
VPN=$(nmcli --get-values NAME,TYPE,ACTIVE connection show --active | grep -E ':(vpn|wireguard):yes$' | cut -d':' -f1 | paste -sd "," -)

# 3. Ausgabe für Waybar generieren
if [ "$CONNECTIVITY" != "full" ]; then
  # Wenn kein Internet vorhanden ist (NONE, LIMITED, PORTAL)
  echo "{\"text\": \"No Internet\", \"class\": \"vpn-disconnected\", \"tooltip\": \"No active Internetconnection\"}"
elif [ -n "$VPN" ]; then
  # Wenn Internet da ist UND mindestens ein VPN aktiv ist
  echo "{\"text\": \"$VPN \", \"class\": \"vpn-connected\", \"tooltip\": \"Connected with: $VPN\"}"
else
  # Wenn Internet da ist, aber KEIN VPN aktiv ist
  echo "{\"text\": \" \", \"class\": \"vpn-disconnected\", \"tooltip\": \"No VPN Connected\"}"
fi
