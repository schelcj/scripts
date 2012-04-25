#!/bin/sh

tmux join-pane -s comm:slrn -t comm:mutt
tmux join-pane -s comm:irssi -t comm:mutt
tmux join-pane -s comm:wyrd -t comm:mutt

tmux select-layout tiled
