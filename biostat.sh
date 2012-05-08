#!/bin/sh

tmux start-server
tmux has-session -t cluster 2>&1 > /dev/null

if [ $? -ne 0 ]; then
  tmux new-session -d -s cluster -n bajor 'ssh bajor'

  tmux new-window -a -d -n idran 'ssh idran'
  tmux new-window -a -d -n denobula 'ssh denobula'
  # tmux new-window -a -d -n andoria 'ssh andoria'
  # tmux new-window -a -d -n vulcan 'ssh vulcan'
  # tmux new-window -a -d -n tellar 'ssh tellar'

  tmux new-session -d -s logs -n syslog-ng 'ssh ardana'

  tmux new-session -d -s flux -n flux 'ssh flux'

  tmux new-session -d -s compute_servers -n compute1 'ssh compute1'
  tmux new-window -a -d -n compute2 'ssh compute2'

  tmux new-session -d -s puppet -n puppet-repo 'cd ~/svn/puppet'

  # tmux new-session -d -s salt -n salt 'ssh salt'
fi

tmux attach -t cluster
