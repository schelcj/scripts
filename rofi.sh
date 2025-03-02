#!/bin/sh
export PATH=$HOME/scripts:$HOME/bin:$HOME/.config/emacs/bin:$PATH

SHOW=$1

rofi \
  -ssh \
  -title true \
  -switchers "window,run,drun,ssh,Workspaces:i3_switch_workspaces.sh" \
  -show ${SHOW:='run'} \
  -location 0 \
  -lines 8

