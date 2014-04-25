#!/bin/sh

tmux start-server
tmux has-session -t biostat 2>&1 > /dev/null

if [ $? -ne 0 ]; then
  tmux new-session -d -s biostat -n bajor 'ssh bajor'
  tmux new-window -a -d -t biostat -n idran 'ssh idran'

  tmux new-session -d -s flux -n flux-login

  tmux new-session -d -s logs -n logs 'ssh syslog'

  tmux new-session -d -s sph-ics
  tmux new-session -d -s misc

  tmux new-session -d -s puppet -n repo 'cd ~/src/puppet'

  tmux new-session -d -s compute-servers -n compute1
  tmux new-window -a -d -t compute-servers -n compute2

  tmux new-session -d -s util -n backuppc 'ssh backuppc'
  tmux new-window -a -d -t util -n cobbler 'ssh cobbler'
  tmux new-window -a -d -t util -n dhcp 'ssh dhcp'
  tmux new-window -a -d -t util -n dns 'ssh dns'
  tmux new-window -a -d -t util -n gw 'ssh gw'
  tmux new-window -a -d -t util -n nagios 'ssh nagios'
  tmux new-window -a -d -t util -n nagios2 'ssh nagios2'
  tmux new-window -a -d -t util -n ns 'ssh ns'
  tmux new-window -a -d -t util -n puppet 'ssh puppet1'
  tmux new-window -a -d -t util -n salt 'ssh salt'
  tmux new-window -a -d -t util -n syslog 'ssh syslog'
  tmux new-window -a -d -t util -n www 'ssh www'
  tmux new-window -a -d -t util -n xfer 'ssh xfer'

  tmux new-session -d -s csg -n dumbo 'ssh dumbo'
fi

tmux attach -t biostat
