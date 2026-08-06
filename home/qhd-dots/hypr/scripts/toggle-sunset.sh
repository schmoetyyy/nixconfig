#!/usr/bin/env bash

# -f sucht im gesamten Befehlsaufruf (also auch im Pfad), nicht nur im Prozessnamen
if pgrep -f "hyprsunset" > /dev/null; then
    # Wenn es läuft -> Töte den Prozess (auch hier ohne -x, sondern mit -f)
    pkill hyprsunset
else
    # Wenn es nicht läuft -> Starte es mit dem Bild im Hintergrund (&)
    hyprsunset -t 2700 &
fi
