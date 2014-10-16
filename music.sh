#!/bin/bash

tmux start-server
tmux has-session -t music 2>&1 > /dev/null

if [ $? -ne 0 ]; then
  tmux new-session -d -s music -n somafm
  tmux new-window -a -d -n pandora
  tmux new-window -a -d -n di
  tmux new-window -a -d -n subsonic
fi

tmux attach -t music
