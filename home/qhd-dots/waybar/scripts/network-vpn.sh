#!/usr/bin/env bash

VPN=$(nmcli --get-values NAME,TYPE,ACTIVE connection show --active | grep -E ':(vpn|wireguard):yes$' | cut -d':' -f1)

if [ -n "$VPN" ]; then
  echo "{\"text\": \"$VPN \", \"class\": \"vpn-connected\", \"tooltip\": \"Verbunden mit $VPN\"}"
else
  echo "{\"text\": \" \", \"class\": \"vpn-disconnected\", \"tooltip\": \"Kein VPN aktiv\"}"
fi
