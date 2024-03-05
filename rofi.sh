#!/bin/sh
export PATH=$HOME/scripts:$PATH

SHOW=$1

rofi \
  -ssh \
  -title true \
  -switchers "window,run,drun,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show ${SHOW:='run'}
#  -location 1 \
#  -theme-str 'window {width: 100%;}' \

