#!/bin/sh

tmux start-server
tmux has-session -t cluster 2>&1 > /dev/null

if [ $? -ne 0 ]; then
  tmux new-session -d -s cluster -n bajor 'mosh bajor'
  tmux new-window -a -d -n idran 'mosh idran'
  tmux new-window -a -d -n denobula 'mosh denobula'
  tmux new-window -a -d -n andoria 'mosh andoria'
  tmux new-window -a -d -n vulcan 'mosh vulcan'
  tmux new-session -d -s logs -n syslog-ng 'mosh syslog'
  tmux new-session -d -s flux -n flux
  tmux new-session -d -s compute_servers -n compute1 'mosh compute1'
  tmux new-window -a -d -n compute2 'mosh compute2'
  tmux new-session -d -s puppet -n repo 'cd src/puppet'
  tmux new-session -d -s salt -n salt 'mosh salt'
fi

tmux attach -t cluster
