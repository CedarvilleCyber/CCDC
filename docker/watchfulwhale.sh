#!/bin/bash
#
# Author: Logan Miller
# Date: 12/30/2024
# File: watchfulwhale.sh
# Status: Nothing done
#
# Purpose: Create a single admin tmux session with one window per scored
# docker service.
# 

ECOMM_WIN="ecomm-state"
WEBMAIL_WIN="webmail-state"
BIND9_WIN="bind9-state"
SPLUNK_WIN="splunk-state"

SESSION_NAME="docker-admin"
QUIT="false"

tmux has-session -t $SESSION_NAME &> /dev/null
if [[ "$?" == "0" ]]; then
	printf "\e[0;31mDashboard for $SESSION_NAME is already running\e[0m\n"
	read -p "Do you want to kill it? [y/n] " REPLACE
	if [[ "$REPLACE" != "y" ]]; then
		QUIT="true"
	else
 		tmux kill-session -t $SESSION_NAME
   	fi
fi

if [[ "$QUIT" != "true" ]]; then

	# Set up tmux session
	tmux new-session -d -s $SESSION_NAME -n admin
	sleep 1

	# Set up ecomm-state window
	WIN_NAME=$ECOMM_WIN
	tmux new-window -n $WIN_NAME
	sleep 1
	tmux split-window -h -t $SESSION_NAME:1
	
	
	sleep .4
	tmux send-keys -t 1 "cd $WIN_NAME" Enter
	sleep .4
	tmux send-keys -t 1 "docker exec -it prestashop bash"

	sleep .4
	tmux send-keys -t 0 "cd $WIN_NAME" Enter
	sleep .4
	tmux send-keys -t 0 "./setup-ecomm.sh"

	# # Set up webmail-state window
	# WIN_NAME=$WEBMAIL_WIN
	# tmux new-window -n $WIN_NAME
	# sleep 1
	# tmux split-window -h -t $SESSION_NAME:2
	
	# # Need to fix
	# # tmux send-keys -t 0 "clear" Enter
	# # tmux send-keys -t 0 "cd $WIN_NAME; ./setup-ecomm.sh"
	# # tmux send-keys -t 1 "cd $WIN_NAME; docker exec -it prestashop bash"

	# # Set up ecomm-state window
	# WIN_NAME=$BIND9_WIN
	# tmux new-window -n $WIN_NAME
	# sleep 1
	# tmux split-window -h -t $SESSION_NAME:3
	
	# # Need to fix
	# # tmux send-keys -t 0 "clear" Enter
	# # tmux send-keys -t 0 "cd $WIN_NAME; ./setup-ecomm.sh"
	# # tmux send-keys -t 1 "cd $WIN_NAME; docker exec -it prestashop bash"

	# # Set up ecomm-state window
	# WIN_NAME=$SPLUNK_WIN
	# tmux new-window -n $WIN_NAME
	# sleep 1
	# tmux split-window -h -t $SESSION_NAME:4
	
	# # Need to fix
	# # tmux send-keys -t 0 "clear" Enter
	# # tmux send-keys -t 0 "cd $WIN_NAME; ./setup-ecomm.sh"
	# # tmux send-keys -t 1 "cd $WIN_NAME; docker exec -it prestashop bash"

	printf "\e[0;32mSuccessfully generated $SESSION_NAME dashboard\e[0m\n"
fi