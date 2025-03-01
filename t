#!/bin/bash
export PATH=$HOME/.nvm/versions/node/v21.7.1/bin:$HOME/node_modules/.bin:$PATH

rtm add $*
#echo $* | mail -s "$*" $(cat $HOME/.config/trello/gtd-addr.txt)
#task add $*
