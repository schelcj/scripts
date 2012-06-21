#!/bin/sh
gnome-terminal \
  --profile 'comm' \
  --command  "mosh --server='LANG=en_US.UTF-8 /usr/local/bin/mosh-server' ressik.dyndns.org"
