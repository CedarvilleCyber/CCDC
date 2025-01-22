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

MACHINE="$1"

case $MACHINE in
    "dns-ntp")     ;;
    "ecomm")       ;;
    "splunk")      ;;
    "web")         ;;
    "webmail")     ;;
    "workstation") ;;
    "")            ;;
    *)
printf "${error}ERROR: Enter respective name according to machine's purpose:
    dns-ntp
    ecomm
    splunk
    web
    webmail
    workstation
    or no parameters for generic${reset}\n"; exit 1 ;;
esac

export MACHINE

# Give user one more chance before running script
printf "\nYou are ${info}"
whoami
printf "${reset}"
printf "Your current working directory is: ${info}"
pwd
printf "${reset}"
if [[ "$MACHINE" == "" ]]
then
    printf "You have chosen the ${info}generic${reset} machine.\n\n"
else
    printf "You have chosen the ${info}$MACHINE${reset} machine.\n\n"
fi


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
if [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "ol" ]]
then
    export PKG_MAN=yum
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]
then
    export PKG_MAN=apt-get

    # disable apt user input
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
else
    export PKG_MAN=apt-get

    # disable apt user input
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    printf "${error}ERROR: Unsupported OS, assuming apt-get${reset}\n"
fi


# Create folders
mkdir /usr/bak
mkdir ./data-files

# clear tmp folder
rm -rf /tmp/*

# firewall automate setup
if [[ "$MACHINE" == "dns-ntp" ]]
then
    printf "53\nt\n53\nu\n123\nu" > ./data-files/ports.txt
elif [[ "$MACHINE" == "ecomm" ]]
then
    printf "80\nt" > ./data-files/ports.txt
elif [[ "$MACHINE" == "splunk" ]]
then
    printf "514\nu\n8000\nt\n8065\nt\n8089\nt\n8191\nt\n9997\nt" > ./data-files/ports.txt
elif [[ "$MACHINE" == "web" ]]
then
    printf "\n" > ./data-files/ports.txt
elif [[ "$MACHINE" == "webmail" ]]
then
    printf "25\nt\n110\nt" > ./data-files/ports.txt
elif [[ "$MACHINE" == "workstation" ]]
then
    printf "\n" > ./data-files/ports.txt
fi


# firewall
if [[ "$MACHINE" == "" ]]
then
    ./firewall.sh
else
    cat ./data-files/ports.txt | ./firewall.sh
fi

# secure os
./secure-os.sh

# make backups
./backup.sh

if [[ -f './data-files/rebooted' ]]
then
    printf "Already updated\n"
else
    touch ./data-files/rebooted
    ./osupdaster
    #printf "\n\n${warn}Updates require reboot. REBOOT right after a scoring check!!${reset}\n\n"
    #exit 0
fi


# quick vimrc for root
printf "set nocompatible\nset backspace=indent,eol,start" > /root/.vimrc

# if run from stage1, then quit now!
if [[ "$2" == "stage1" ]]
then
    exit 0
fi


# download pspy
# regex for 64 to find out which one to download
ARCH=`uname -m`
if [[ "$ARCH" =~ .*64.* ]]
then
    wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
    chmod 700 ./pspy64
else
    wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy32
    chmod 700 ./pspy32
fi

# fix old mirror links for apt/yum
./eol-mirrors.sh

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
        yum install epel-release -y
        yum install tmux -y
    fi
fi

which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    ./no-tmux.sh
    printf "${error}QUITTING! Failed to install tmux${reset}\n"
    printf "${info}Ran background tasks only.${reset}\n"
    printf "${info}Please run other scripts seperately if necessary${reset}\n"
    exit 1
fi


SESSION_NAME="Work"
SESSIONEXISTSW=$(tmux ls | grep $SESSION_NAME)
SESSION_NAME="Once"
SESSIONEXISTSO=$(tmux ls | grep $SESSION_NAME)
SESSION_NAME="Background"
SESSIONEXISTSB=$(tmux ls | grep $SESSION_NAME)

# See if session exists, then ask if you want to remake sessions
if [[ "$SESSIONEXISTSW" != "" ]] || [[ "$SESSIONEXISTSO" != "" ]] || [[ "$SESSIONEXISTSB" != "" ]]
then
    printf "${info}Tmux sessions exist.${reset}\n"
    printf "${info}Would you like to delete and remake them? [y/n]: ${reset}"
    read input
    if [[ "$input" != "Y" ]] || [[ "$input" != "y" ]]
    then
        # skip the rest of the script where tmux is run
        ./no-tmux.sh
        printf "\n${info}Pansophy complete. Are your eyes open?${reset}\n\n"
        exit 0
    fi
fi

# Name session Background
SESSION_NAME="Background"
SESSIONEXISTS=$(tmux ls | grep $SESSION_NAME)

QUIT="false"

# Make sure session doesn't already exist
if [[ "$SESSIONEXISTS" != "" ]]
then
    printf "${warn}Session \"$SESSION_NAME\" already exists!${reset}\n"
    printf "Would you like to delete and remake \"$SESSION_NAME\"? [y/n]: "
    read input
    if [[ "$input" != "Y" ]] || [[ "$input" != "y" ]]
    then
        QUIT="true"
    else
        tmux kill-session -t $SESSION_NAME
    fi
fi

if [[ "$QUIT" != "true" ]]
then
    # create a new session
    tmux new-session -d -s $SESSION_NAME
    # Stopping tmux rename so our window names can work
    tmux set-option -g allow-rename off

    # First window (already created)
    tmux rename-window -t 0 "Background"
    tmux send-keys -t "Background" "./background.sh" C-m

    # Second window for secure-os.sh background loop
    tmux new-window -t $SESSION_NAME:1 -n "secure_loop"
    tmux send-keys -t "secure_loop" "cmd='./secure-os.sh background'; while (true); do \$cmd; sleep 180; clear -x; sleep 1; done" C-m
fi

# Name session Once
SESSION_NAME="Once"
SESSIONEXISTS=$(tmux ls | grep $SESSION_NAME)

QUIT="false"

# Make sure session doesn't already exist
if [[ "$SESSIONEXISTS" != "" ]]
then
    printf "${warn}Session \"$SESSION_NAME\" already exists!${reset}\n"
    printf "Would you like to delete and remake \"$SESSION_NAME\"? [y/n]: "
    read input
    if [[ "$input" != "Y" ]] || [[ "$input" != "y" ]]
    then
        QUIT="true"
    else
        tmux kill-session -t $SESSION_NAME
    fi
fi

if [[ "$QUIT" != "true" ]]
then
    # create a new session
    tmux new-session -d -s $SESSION_NAME
    # Stopping tmux rename so our window names can work
    tmux set-option -g allow-rename off

    # First window (already created)
    tmux rename-window -t 0 "Bash"

    # Reserve second window for ntp later on
    tmux new-window -t $SESSION_NAME:1 -n "ntp"

    # Reserve third window for nmap later on
    tmux new-window -t $SESSION_NAME:2 -n "nmap"

    # window for Basic Info
    tmux new-window -t $SESSION_NAME:3 -n "info"
    tmux send-keys -t "info" "./basic-info.sh" C-m

    # window for login-banner/ssh
    tmux new-window -t $SESSION_NAME:4 -n "banner"
    tmux send-keys -t "banner" "./login-banners.sh" C-m
    # ssh to self to get banner
    # skip the host key checking thing
    tmux send-keys -t "banner" "timeout 5 ssh -o StrictHostKeychecking=no `whoami`@127.0.0.1" C-m

    # window for checking cron
    tmux new-window -t $SESSION_NAME:5 -n "cron"
    tmux send-keys -t "cron" "./check-cron.sh" C-m

    # window for splunk
    tmux new-window -t $SESSION_NAME:6 -n "splunk"
    tmux send-keys -t "splunk" "cd ./logging" C-m
    tmux send-keys -t "splunk" "./install_and_setup_forwarder.sh" C-m

    # window for rkhunter results
    tmux new-window -t $SESSION_NAME:7 -n "rkhunter"
    tmux send-keys -t "rkhunter" "less \`find /var/log -iname \"rkhunter.log\"\`"
fi

# Name session Work
# Everything you need right in front of you
SESSION_NAME="Work"
SESSIONEXISTS=$(tmux ls | grep $SESSION_NAME)

QUIT="false"

# Make sure session doesn't already exist
if [[ "$SESSIONEXISTS" != "" ]]
then
    printf "${warn}Session \"$SESSION_NAME\" already exists!${reset}\n"
    printf "Would you like to delete and remake \"$SESSION_NAME\"? [y/n]: "
    read input
    if [[ "$input" != "Y" ]] || [[ "$input" != "y" ]]
    then
        QUIT="true"
    else
        tmux kill-session -t $SESSION_NAME
    fi
fi

if [[ "$QUIT" != "true" ]]
then
    # create a new session
    tmux new-session -d -s $SESSION_NAME

    # First window for a whatever needs to be done (already created)
    tmux rename-window -t 0 "Bash"
    # Send keys to tmux window
    # cd into machine-scripts for conveniency
    # C-m is <ENTER>

    # window for pspy
    tmux new-window -t $SESSION_NAME:1 -n "pspy"
    tmux send-keys -t "pspy" "./pspy*" C-m

    # window for processes
    tmux new-window -t $SESSION_NAME:2 -n "procs"
    # the last few commands are refreshed every minute
    tmux send-keys -t "procs" "cmd='ps -fea --forest'; while (true); do \$cmd; sleep 60; clear -x; sleep 0.5; done" C-m

    # window for users
    tmux new-window -t $SESSION_NAME:3 -n "users"
    tmux send-keys -t "users" "cmd='./user-sort.sh'; while (true); do \$cmd; sleep 60; clear -x; sleep 0.5; done" C-m

    # window for services
    tmux new-window -t $SESSION_NAME:4 -n "services"
    tmux send-keys -t "services" "./disable-services.sh" C-m

    # window for ports
    tmux new-window -t $SESSION_NAME:5 -n "ports"
    tmux send-keys -t "ports" "cmd='./connections.sh'; while (true); do \$cmd; sleep 60; clear -x; sleep 0.5; done" C-m

    # Attach to the work session
    tmux attach-session -t $SESSION_NAME
fi


printf "\n${info}Pansophy complete. Are your eyes open?${reset}\n\n"

exit 0

