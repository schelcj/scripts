#!/bin/sh

# According to http://phihag.de/2012/thinkpad-docking.html
# the following acpi events need to be added to make
# this work.
#
# cat >/etc/acpi/events/thinkpad-dock-ibm <<EOF
# event=ibm/hotkey IBM0068:00 00000080 00004010
# action=su $SUDO_USER -c /etc/acpi/thinkpad-dock.sh
# EOF
#
# cat >/etc/acpi/events/thinkpad-dock-lenovo <<EOF
# event=ibm/hotkey LEN0068:00 00000080 00004010
# action=su $SUDO_USER -c /etc/acpi/thinkpad-dock.sh
# EOF
#
# cat >/etc/acpi/events/thinkpad-undock-ibm <<EOF
# event=ibm/hotkey IBM0068:00 00000080 00004011
# action=su $SUDO_USER -c /etc/acpi/thinkpad-undock.sh
# EOF
#
# cat >/etc/acpi/events/thinkpad-undock-lenovo <<EOF
# event=ibm/hotkey LEN0068:00 00000080 00004011
# action=su $SUDO_USER -c /etc/acpi/thinkpad-undock.sh
# EOF
#

sleep 2

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

  #xrandr -d :0.0 --output LVDS1 --auto --primary --mode 1600x900 --output VGA1 --off

  for output in $(xrandr -d :0.0 --verbose|grep " connected"|grep -v LVDS|awk '{print $1}'); do
    xrandr -d :0.0 --output $output --off
  done

  nmcli nm wifi on
  nmcli con down id 'Biostat Cluster'

  amixer set Master mute
}

case "$(basename $0)" in
  "thinkpad-undock.sh")
    undock
    ;;
  "thinkpad-dock.sh")
    dock
    ;;
esac

exit 0
