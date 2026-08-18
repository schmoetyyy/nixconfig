#!/usr/bin/env bash


if pgrep -f "wl-crosshair" > /dev/null; then
    pkill -f "wl-crosshair"
else
    wl-crosshair /home/schmoetyyy/nixconfig/home/qhd-dots/crosshairs/cross5.png &
fi
