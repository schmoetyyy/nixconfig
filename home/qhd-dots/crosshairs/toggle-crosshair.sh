#!/usr/bin/env bash

# -f sucht im gesamten Befehlsaufruf (also auch im Pfad), nicht nur im Prozessnamen
if pgrep -f "wl-crosshair" > /dev/null; then
    # Wenn es läuft -> Töte den Prozess (auch hier ohne -x, sondern mit -f)
    pkill -f "wl-crosshair"
else
    # Wenn es nicht läuft -> Starte es mit dem Bild im Hintergrund (&)
    wl-crosshair /home/schmoetyyy/nixconfig/home/qhd-dots/crosshairs/cross5.png &
fi
