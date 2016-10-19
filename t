#!/bin/sh
rtm add $*
echo $* | mail -s "$*" $(cat $HOME/.config/trello/gtd-addr.txt)
#task add $*
