#!/bin/sh

for i in 1 2; do
  xrandr --auto --output LVDS1 --left-of DP-2
done
