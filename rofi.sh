#!/bin/sh
#  -bg "#484e50" \
#  -fg "#ffffff" \
#  -width 100 \
#  -location 1 \
#  -lines 5 \

rofi \
  -padding 1 \
  -ssh \
  -set \
  -title true \
  -switchers "window,run,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show window
