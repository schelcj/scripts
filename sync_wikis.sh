#!/bin/sh

gnsync -p ~/Dropbox/Wikis/Default -f markdown -n Wiki -l ~/tmp/gnsync.log -t TWO_WAY

# XXX - causes duplicate notes to be created, why?
#gnsync -p ~/Dropbox/Wikis/Default/journal -f markdown -n Journal -l ~/tmp/gnsync.log -t TWO_WAY
