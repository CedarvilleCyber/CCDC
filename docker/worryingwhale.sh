#!/bin/bash
#
# Author: Logan Miller
# Date: 12/30/2024
# File: worryingwhale.sh
# Status: Tested and working, need to test w/ docker running, though
# 
# Purpose: Construct individual dashboards for each scored docker service. 
# This permits each service to be monitored by separate users if necessary.
#
# Note: Currently each dashboard setup is nearly identical. A loop could be 
# introduced for code efficiency, but setup may end up being more custom for
# each service at some point in the future.
#

ECOMM_SES="ecomm-state"
WEBMAIL_SES="webmail-state"
BIND9_SES="bind9-state"
SPLUNK_SES="splunk-state"

WIN_NAME="dashboard"
QUIT="false"

# Set up ecomm-state dashboard
SESSION_NAME=$ECOMM_SES
cd $SESSION_NAME
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

	tmux new-session -d -s $SESSION_NAME -n $WIN_NAME
	sleep 1
	
	tmux split-window -h -t $SESSION_NAME:0
	tmux split-window -v -t 1
	sleep 1
	
	# Prep tmux dashboard with admin commands
	tmux send-keys -t 0 "clear" Enter
	tmux send-keys -t 0 "docker compose -f docker-compose.yaml --env-file ../ccdc.env up --remove-orphans"
	tmux send-keys -t 1 "docker exec -it prestashop bash"
	tmux send-keys -t 2 "docker logs -f prestashop"

	QUIT="false"
	cd ..
	printf "\e[0;32mSuccessfully generated $SESSION_NAME dashboard\e[0m\n"
fi

# Set up webmail-state dashboard
SESSION_NAME=$WEBMAIL_SES
cd $SESSION_NAME
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

	tmux new-session -d -s $SESSION_NAME -n $WIN_NAME
	sleep 1
	
	tmux split-window -h -t $SESSION_NAME:0
	tmux split-window -v -t 1
	sleep 1
	
	# Prep tmux dashboard with admin commands
	tmux send-keys -t 0 "clear" Enter
	tmux send-keys -t 0 "docker compose -f docker-compose.yaml --env-file ../ccdc.env up --remove-orphans"
	tmux send-keys -t 1 "docker exec -it webmail bash"
	tmux send-keys -t 2 "docker logs -f webmail"

	QUIT="false"
	cd ..
	printf "\e[0;32mSuccessfully generated $SESSION_NAME dashboard\e[0m\n"
fi

# Set up bind9-state dashboard
SESSION_NAME=$BIND9_SES
cd $SESSION_NAME
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

	tmux new-session -d -s $SESSION_NAME -n $WIN_NAME
	sleep 1
	
	tmux split-window -h -t $SESSION_NAME:0
	tmux split-window -v -t 1
	sleep 1
	
	# Prep tmux dashboard with admin commands
	tmux send-keys -t 0 "clear" Enter
	tmux send-keys -t 0 "docker compose -f docker-compose.yaml --env-file ../ccdc.env up --remove-orphans"
	tmux send-keys -t 1 "docker exec -it bind9 bash"
	tmux send-keys -t 2 "docker logs -f bind9"

	QUIT="false"
	cd ..
	printf "\e[0;32mSuccessfully generated $SESSION_NAME dashboard\e[0m\n"
fi

# Set up splunk-state dashboard
SESSION_NAME=$SPLUNK_SES
cd $SESSION_NAME
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

	tmux new-session -d -s $SESSION_NAME -n $WIN_NAME
	sleep 1
	
	tmux split-window -h -t $SESSION_NAME:0
	tmux split-window -v -t 1
	sleep 1
	
	# Prep tmux dashboard with admin commands
	tmux send-keys -t 0 "clear" Enter
	tmux send-keys -t 0 "docker compose -f docker-compose.yaml --env-file ../ccdc.env up --remove-orphans"
	tmux send-keys -t 1 "docker exec -it splunk bash"
	tmux send-keys -t 2 "docker logs -f splunk"

	QUIT="false"
	cd ..
	printf "\e[0;32mSuccessfully generated $SESSION_NAME dashboard\e[0m\n"
fi

if (( $(($(date +%s) % 10)) == 7 )); then
    printf "\e[0;32m\nAll dashboards are running! You'd better catch them!\e[0m\n\n"
else
    printf "\e[0;32m\nAll dashboards are running!\e[0m\n\n"
fi