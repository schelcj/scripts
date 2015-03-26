#!/bin/sh
rofi \
  -location 1 \
  -width 100 \
  -bg "#484e50" \
  -fg "#ffffff" \
  -padding 0 \
  -ssh \
  -set \
  -title true \
  -switchers "window,run,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show window
