#!/bin/bash
# 
# pansophy.sh
# Pansophy - Universal wisdom/knowledge
# 
# The ultimate Linux sysadmin hardening script. Your eyes will be opened...
# 
# Kaicheng Ye
# Dec. 2023


# Use colors, but only if connected to a terminal
# and if the terminal supports colors
if which tput >/dev/null 2>&1
then
    ncolors=$(tput colors)
fi
if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]
then
    export info=$(tput setaf 2)
    export error=$(tput setaf 1)
    export warn=$(tput setaf 3)
    export reset=$(tput sgr0)
else
    export info=""
    export error=""
    export warn=""
    export reset=""
fi


# Check if script has been run with superuser privileges
if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi


# Give user one more chance before running script
printf "\n${info}You are "
whoami
printf "${reset}"
printf "Your current working directory is: ${info}"
pwd
printf "${reset}\n"
printf "Continue running script? [y/n]: "

# Get user input
read input

# Check user input
if [[ $input == "N" ]] || [[ $input == "n" ]]
then
    printf "Script Ended.\n"
    exit 0
fi


# Set up some environment variables
. /etc/os-release

# Package Manager
if [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" ]]
then
    export PKG_MAN=yum
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]
then
    export PKG_MAN=apt-get
else
    export PKG_MAN=apt-get
    printf "${error}ERROR: Unsupported OS, assuming apt-get${reset}\n"
fi


# Create folders
mkdir /opt/bak
mkdir ./data-files

# clear tmp folder
rm -rf /tmp/*

# firewall
./firewall.sh

# secure os
./secure-os.sh

# make backups
./backup.sh

# quick vimrc for root
printf "set nocompatible\nset backspace=indent,eol,start" > /root/.vimrc

# start tmux
which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    printf "${info}Attempting to install tmux${reset}\n"
    if [[ "$PKG_MAN" == "apt-get" ]]
    then
        apt-get update
        apt-get install tmux -y --force-yes
    else
        yum clean expire-cache
        yum check-update
        yum install tmux -y
    fi
fi

which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    ./no-tmux.sh
    printf "${error}QUITTING! Failed to install tmux${reset}\n"
    printf "${error}Ran background tasks only.${reset}\n"
    printf "${error}Please run scripts seperately${reset}\n"
    exit 1
fi

# Name session Background
# Everything you need right in front of you
SESSIONB="Background"
SESSIONEXISTS=$(tmux ls | grep $SESSIONB)

# Make sure session doesn't already exist
if [[ "$SESSIONEXISTS" == "" ]]
then
    # create a new session
    tmux new-session -d -s $SESSIONB
    # Stopping tmux rename so our window names can work
    tmux set-option -g allow-rename off

    # First window for a bash session (already created)
    tmux rename-window -t 0 "Tasks"
    # Read about part2.sh in it's header
    tmux send-keys -t "Tasks" "./part2.sh" C-m
else
    printf "${warn}Session \"$SESSIONB\" already exists!${reset}\n"
fi

# Name session Work
# Everything you need right in front of you
SESSIONW="Work"
SESSIONEXISTS=$(tmux ls | grep $SESSIONW)

# Make sure session doesn't already exist
if [[ "$SESSIONEXISTS" == "" ]]
then
    # create a new session
    tmux new-session -d -s $SESSIONW

    # First window for a whatever needs to be done (already created)
    tmux rename-window -t 0 "Bash"
    # Send keys to tmux window
    # cd into machine-scripts for conveniency
    # C-m is <ENTER>
    tmux send-keys -t "Bash" "cd ./machine-scripts" C-m

    # Reserve second window for ntp later on
    tmux new-window -t $SESSIONW:1 -n "ntp"

    # Reserve third window for nmap later on
    tmux new-window -t $SESSIONW:2 -n "nmap"

    # window for Basic Info
    tmux new-window -t $SESSIONW:3 -n "info"
    tmux send-keys -t "info" "./basic-info.sh" C-m

    # window for login-banner/ssh
    tmux new-window -t $SESSIONW:4 -n "banner"
    tmux send-keys -t "banner" "./login-banners.sh" C-m
    # ssh to self to get banner
    # skip the host key checking thing
    tmux send-keys -t "banner" "timeout 5 ssh -o StrictHostKeychecking=no `whoami`@127.0.0.1" C-m

    # window for checking cron
    tmux new-window -t $SESSIONW:5 -n "cron"
    tmux send-keys -t "cron" "./check-cron.sh" C-m

    # window for splunk
    tmux new-window -t $SESSIONW:6 -n "splunk"
    tmux send-keys -t "splunk" "cd ./logging" C-m
    tmux send-keys -t "splunk" "./install_and_setup_forwarder.sh" C-m

    # window for rkhunter results
    tmux new-window -t $SESSIONW:7 -n "rkhunter"
    tmux send-keys -t "rkhunter" "less \`find /var/log -iname \"rkhunter.log\"\`"

    # window for processes
    tmux new-window -t $SESSIONW:8 -n "procs"
    # the last few commands are refreshed every minute
    tmux send-keys -t "procs" "cmd='ps -fea --forest'; while (true); do \$cmd; sleep 60; clear -x; sleep 1; done" C-m

    # window for users
    tmux new-window -t $SESSIONW:9 -n "users"
    tmux send-keys -t "users" "cmd='./user-sort.sh'; while (true); do \$cmd; sleep 60; clear -x; sleep 1; done" C-m

    # window for services
    tmux new-window -t $SESSIONW:10 -n "services"
    tmux send-keys -t "services" "cmd='./service-sort.sh'; while (true); do \$cmd; sleep 60; clear -x; sleep 1; done" C-m

    # window for ports
    tmux new-window -t $SESSIONW:11 -n "ports"
    tmux send-keys -t "ports" "cmd='./connections.sh'; while (true); do \$cmd; sleep 60; clear -x; sleep 1; done" C-m

    # Attach to the work session
    tmux attach-session -t $SESSIONW
else
    printf "${warn}Session \"$SESSIONW\" already exists!${reset}\n"
fi


printf "\n${info}Pansophy complete. Are your eyes open?${reset}\n\n"

exit 0

