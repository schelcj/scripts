#!/bin/sh
#  --command  "mosh -n --server='LANG=en_US.UTF-8 /storage/software/slackware12/mosh/1.2.2/bin/mosh-server' ressik.dyndns.org"
gnome-terminal --profile 'comm' --command "${HOME}/scripts/trapper.sh"
