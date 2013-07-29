#!/bin/sh

tmux start-server
tmux has-session -t comm 2>&1 > /dev/null

if [ $? -ne 0 ]; then
  tmux new-session -d -s comm

  tmux new-window -a -d -n weechat weechat-curses
  tmux new-window -a -d -n wyrd wyrd
  tmux new-window -a -d -n slrn slrn
  tmux new-window -a -d -n mutt mutt

  tmux kill-window -t comm:0
  tmux move-window -s comm:mutt -s comm:0

  # tmux set-option status off

  tmux join-pane -t comm:mutt -s comm:wyrd
  tmux join-pane -t comm:mutt -s comm:weechat
  tmux join-pane -t comm:mutt -s comm:slrn

  tmux select-layout tiled

  # tmux move-window -s comm:1 -t comm:3
  # tmux move-window -s comm:0 -t comm:1
  # tmux move-window -s comm:offlineimap -t comm:1
  # tmux move-window -s comm:mutt -t comm:0
  # tmux move-window -s comm:tasks -t comm:2
fi

tmux attach -t comm
