#!/bin/bash

# Ensure script is run as root
if [[ $(id -u) != "0" ]]; then
    echo "You must be root to run this script!" >&2
    exit 1
fi

apt-get install tmux -y
yum install tmux -y

tmux new-session -d -s "master"
tmux rename-window -t 0 "bash"

tmux new-window -t "master":1 -n "script"
tmux send-keys -t "script" "./script-dependencies/master-script.sh" C-m

tmux attach-session -t "master"

exit 0