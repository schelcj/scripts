#!/bin/sh
#  -location 1 \
#  -width 100 \
#  -switchers "window,run,ssh,Workspaces:i3_switch_workspaces.sh" \
#  -bg "#484e50" \
#  -fg "#ffffff" \

rofi \
  -padding 0 \
  -ssh \
  -set \
  -title true \
  -switchers "run,window,ssh" \
  -show run
