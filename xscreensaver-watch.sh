#!/bin/sh
xscreensaver-command -watch | while read event rest; do
case $event in
  "LOCK"|"BLANK")
    pkill -USR1 -x -u `id -u` dunst
    logger Paused dunst
    ;;
  "UNBLANK")
    pkill -USR2 -x -u `id -u` dunst
    logger Resumed dunst
    ;;
esac
done
