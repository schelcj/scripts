#!/bin/sh
xrandr --output DP-2-2 --primary
sleep 2
xrandr --output eDP-1 --off
sleep 2
i3-msg restart
