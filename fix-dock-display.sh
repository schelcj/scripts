#!/bin/sh

for i in 1 2; do
  xrandr --auto --output LVDS-1-0 --left-of DP-2
done
