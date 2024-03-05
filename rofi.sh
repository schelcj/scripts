#!/bin/sh
export PATH=$HOME/scripts:$PATH

export PATH=$HOME/scripts:$HOME/bin:$PATH
SHOW=$1

rofi \
  -ssh \
  -title true \
  -switchers "window,run,drun,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show ${SHOW:='run'} \
  -width 30 \
  -location 0 \
  -lines 8

