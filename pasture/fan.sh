#!/bin/bash

dev="/sys/class/hwmon/hwmon0/device/pwm2"

case "$1" in
  'max')
    echo 240 > $dev
    ;;
  'med')
    echo 128 > $dev
    ;;
  'low')
    echo 0 > $dev
    ;;
  'set')
    echo $2 > $dev
    ;;
  'status')
    cat $dev
    ;;
  *)
    echo "Usage: $0 [max|med|low|status]"
    exit 1
esac

exit 0
