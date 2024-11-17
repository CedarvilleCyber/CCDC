#!/bin/bash

ECOMM_SES="ecomm-state"
WEBMAIL_SES="webmail-state"
BIND9_SES="bind9-state"
SPLUNK_SES="splunk-state"

WIN_NAME="dashboard"
QUIT="false"

# Set up ecomm-state dashboard
SESSION_NAME=$ECOMM_SES
tmux has-session -t $SESSION_NAME &> /dev/null
if [[ "$?" == "0" ]]; then
	read -p "Dashboard for ecomm-state already exists. Do you want to kill it? [y/n] " REPLACE
	if [[ "$REPLACE" != "y" ]]; then
		QUIT="true"
	else
 		tmux kill-session -t $SESSION_NAME
   	fi
fi

if [[ "$QUIT" != "true" ]]; then

	tmux new-session -d -s $SESSION_NAME -n $WIN_NAME
	sleep 1
	
	tmux split-window -h -t $SESSION_NAME:0
	tmux split-window -v -t 1
	sleep 1
	
	tmux send-keys -t 0 "docker ps" Enter
	tmux send-keys -t 1 "docker exec -it THINGY bash" Enter # FIXME
	tmux send-keys -t 2 "docker log -f THINGY" Enter # FIXME
fi

