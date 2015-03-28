#!/bin/sh

STATE="$(awk {'print $2'} /proc/acpi/ac_adapter/AC/state)"

function set_cpu_gov() {
  local governor
  governor=$1

  for i in $(cat /proc/cpuinfo|grep processor|awk {'print $3'}); do
      cpufreq-set -g $governor -c $i
  done
}

logger "AC Adapter changed state to $STATE"

case "$STATE" in
  'on-line')
    set_cpu_gov "ondemand"
    pm-powersave false
    ;;
  'off-line')
    set_cpu_gov "powersave"
    pm-powersave true
    ;;
esac

exit
