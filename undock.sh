#!/bin/sh

export PATH=${HOME}/scripts:${HOME}/bin:${PATH}

xrandr -d :0.0 --output LVDS1 --auto --primary --mode 1600x900 --output VGA1 --off
nmcli nm wifi on
nmcli con down id 'Biostat Cluster'
wallpaper.pl
rm ${HOME}/.config/openvpn/openvpn.pid
