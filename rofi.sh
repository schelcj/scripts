#!/bin/sh
#  -bg "#484e50" \
#  -fg "#ffffff" \

rofi \
  -location 1 \
  -width 100 \
  -padding 0 \
  -lines 5 \
  -ssh \
  -set \
  -title true \
  -switchers "window,run,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show run
