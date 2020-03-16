#!/bin/sh
#xrandr --output DP-2-1 --auto
#sleep 2
#xrandr --output DP-2-1 --primary
#sleep 2
#xrandr --output eDP-1 --off
#sleep 2

#xrandr --output DP-2-1 --off
xrandr --output DP-2-1 --auto
xrandr --output DP-2-1 --left-of eDP-1
xrandr --output DP-2-1 --primary

i3-msg restart
