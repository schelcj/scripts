#!/bin/sh

export PATH=${HOME}/scripts:${HOME}/bin:${PATH}

xrandr -d :0.0 --output VGA1 --auto --primary --mode 1920x1200 --output LVDS1 --off
nmcli nm wifi off
nmcli con up id 'Biostat Cluster'
wallpaper.pl
pidof openvpn > ${HOME}/.config/openvpn/openvpn.pid
