#!/bin/sh
gnome-terminal \
  --profile 'comm' \
  --command  "mosh -n --server='LANG=en_US.UTF-8 /storage/software/slackware12/mosh/1.2.2/bin/mosh-server' ressik.dyndns.org"
