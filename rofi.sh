#!/bin/sh
#  -bg "#484e50" \
#  -fg "#ffffff" \
#  -width 100 \
#  -location 1 \
#  -lines 5 \

SHOW=$1

rofi \
  -padding 1 \
  -ssh \
  -set \
  -title true \
  -switchers "window,run,drun,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show ${SHOW:='run'} \
  -width 50 \
  -location 0

