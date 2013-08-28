#!/bin/sh

export PATH=${HOME}/scripts:${HOME}/bin:${PATH}

function dock() {
  logger "docking event called from $0"

  #xrandr -d :0.0 --output LVDS-1 --auto --output DP-3 --mode 1920x1200 --primary --right-of LVDS-1
  #xrandr -d :0.0 --output VGA1 --auto --primary --mode 1920x1200 --output LVDS1 --off

  nmcli nm wifi off
  nmcli con up id 'Biostat Cluster'

  amixer set Master unmute
}

function undock() {
  logger "undocking event called from $0"

  test -f /usr/share/acpi-support/key-constants || exit 0

  for device in /sys/devices/platform/dock.*; do
    [ -e "$device/type" ] || continue
    [ x$(cat "$device/type") = xdock_station ] || continue
    echo 1 > "$device/undock"
  done

  #xrandr -d :0.0 --output LVDS1 --auto --primary --mode 1600x900 --output VGA1 --off
  for output in $(xrandr -d :0.0 --verbose|grep " connected"|grep -v LVDS|awk '{print $1}'); do
    xrandr -d :0.0 --output $output --off
  done

  nmcli nm wifi on
  nmcli con down id 'Biostat Cluster'

  amixer set Master mute
}

Dfunction turn_off_displays() {
}

OCKED=$(cat /sys/devices/platform/dock.1/docked)

sleep 0.5

case "$DOCKED" in
  0)
    undock
    ;;
  1)
    dock
    ;;
esac

exit 0
