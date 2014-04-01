#!/bin/sh

if [ -z "$(pidof xscreensaver)" ]; then
  xscreensaver -no-splash &
fi

xscreensaver-command -lock
