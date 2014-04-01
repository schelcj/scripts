#!/bin/sh

tmux join-pane -s comm:slrn           -t comm:0
tmux join-pane -s comm:weechat-curses -t comm:0
tmux join-pane -s comm:mutt           -t comm:0
tmux join-pane -s comm:newsbeuter     -t comm:0

tmux select-layout tiled
