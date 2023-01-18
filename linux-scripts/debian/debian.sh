#!/bin/bash

clear


# formatting text
# Use colors, but only if connected to a terminal
# and that terminal supports colors
if which tput >/dev/null 2>&1; then
	ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
	info=$(tput setaf 2)
	error=$(tput setaf 1)
	warn=$(tput setaf 3)
	reset=$(tput sgr0)
else
	info=""
	error=""
	warn=""
	reset=""
fi


# Debian Script

if [ "$(id -u)" != "0" ]; then
	printf "You must be a superuser!\n"
	printf "Meaning you are currently not super enough!\n"
	exit 1
fi

# Give user one more chance before running script

printf "You are "
whoami
printf "\n"
printf "Your current working directory is "
pwd
printf "Continue running script? [y/n]: "
read input

if [ $input == "N" ] || [ $input == "n" ]; then
	printf "Script Ended.\n"
	exit 0
fi

printf "Packages Updated!\n"


# basic security
printf "Removing unnecessary packages...\n"

# purge deletes configuration files with it
systemctl disable telnet
apt-get purge telnet -y
apt-get purge nc -y
apt-get purge john -y

printf "Stopping unnecessary services...\n"
systemctl disable sshd
systemctl disable ssh.service
systemctl disable rpcbind
systemctl disable nfs-server
systemctl disable dovecot
systemctl disable slapd
systemctl disable vsftpd
systemctl disable snmpd
systemctl disable exim4
systemctl disable snmp
systemctl disable pop3
systemctl disable icmp
systemctl disable sendmail
systemctl stop sshd
systemctl stop ssh.service
systemctl stop rpcbind
systemctl stop nfs-server
systemctl stop dovecot
systemctl stop slapd
systemctl stop vsftpd
systemctl stop snmpd
systemctl stop exim4
systemctl stop snmp
systemctl stop pop3
systemctl stop icmp
systemctl stop sendmail
printf "Use (service <service name> status) to show status\n"

printf "Removed!\n"

# turn bind9 on though
systemctl start bind9

# install sudo
apt-get install sudo

printf "Scanners and Configuring Firewall...\n"
apt-get install clamav clamav-daemon -y
freshclam
apt-get install lynis -y
apt-get install fail2ban -y
apt-get install ufw -y
ufw allow dns
ufw allow ntp
ufw allow http
ufw allow https
ufw enable

printf "Make sure there are no werid rules in iptables and ufw!\n"
printf "Do that manually!\n"

# Install other stuff
apt-get install libpam-pwquality -y
apt-get install libpam-tmpdir -y
apt-get install debian-goodies -y

# make .vimrc
printf "set nocompatible\nset backspace=indent,eol,start" > /root/.vimrc
printf "set nocompatible\nset backspace=indent,eol,start" > ~/.vimrc


# Set up tmux
printf "Setting up tmux...\n"
apt-get install tmux -y

# name session Background
# Have programs running in the background
SESSIONB="Background"
SESSIONEXISTS=$(tmux ls | grep $SESSIONB)

# Check if session already exists
if [ "$SESSIONEXISTS" == "" ]; then
	# doesn't already exist
	tmux new-session -d -s $SESSIONB
	
	# First window (already created)
	tmux rename-window -t 0 "Bash"
	
	# Second window for Clamav
	tmux new-window -t $SESSIONB:1 -n "ClamAv"
	# Send text to "ClamAv" window
	# C-m means <enter>
	tmux send-keys -t "ClamAv" "clamscan -i -r / -l clamav.log" C-m

	# Third window for lynis
	# lynis will search for vulnerabilities what you should to to fix them
	tmux new-window -t $SESSIONB:2 -n "Lynis"
	tmux send-keys -t "Lynis" "lynis audit system --quick > lynis.log" C-m
	
	# Attach session
	#tmux attach-session -t $SESSIONB
else
	printf "${warn}Session \"$SESSIONB\" already exists!${reset}\n"
fi

# name session Work
SESSIONW="Work"
SESSIONEXISTS=$(tmux ls | grep $SESSIONW)

# Check if session already exists
if [ "$SESSIONEXISTS" == "" ]; then
	# doesn't already exist
	tmux new-session -d -s $SESSIONW
	
	# First window (already created)
	tmux rename-window -t 0 "Bash"
	# write command to check ntp
	tmux send-keys -t "Bash" "./ntpRestart.sh"
	
	# Second window for ntp
	apt-get install ntp -y
	tmux new-window -t $SESSIONW:1 -n "NTPConfig"
	tmux send-keys -t "NTPConfig" "vi /etc/ntp.conf" C-m

	# Third window for Clamav
	tmux new-window -t $SESSIONW:2 -n "ClamAvParse"
	# Sleep to wait for the shell to load
	sleep 0.1
	tmux send-keys -t "ClamAvParse" "### Make sure to wait for clamav to finish! ###" C-m
	tmux send-keys -t "ClamAvParse" "vi clamav.log"

	# Forth window for lynis
	tmux new-window -t $SESSIONW:3 -n "LynisParse"
	#sleep 0.1
	tmux send-keys -t "LynisParse" "### Make sure to wait for lynis to finish! ###" C-m
	tmux send-keys -t "LynisParse" "grep suggestion /var/log/lynis-report.dat | less -Xr"
	
	# Fifth window for checking users
	tmux new-window -t $SESSIONW:4 -n "CheckUsers"
	tmux send-keys -t "CheckUsers" "./userSort.sh | less -Xr" C-m

	# Sixth window for checking services
	tmux new-window -t $SESSIONW:5 -n "CheckServices"
	tmux send-keys -t "CheckServices" "./serviceSort.sh | less -Xr" C-m

	# Seventh window for checking crontab, ufw, and iptables
	tmux new-window -t $SESSIONW:6 -n "CheckCron+Wall"
	tmux send-keys -t "CheckCron+Wall" "cd /var/spool/cron/crontabs" C-m
	tmux send-keys -t "CheckCron+Wall" "ls -al" C-m

	# Attach session
	#tmux attach-session -t $SESSIONW
else
	printf "${warn}Session \"$SESSIONW\" already exists!${reset}\n"
fi

# New Session Monitor
SESSIONM="Moni"
SESSIONEXISTS=$(tmux ls | grep $SESSIONM)

if [ "$SESSIONEXISTS" == "" ]; then
	tmux new-session -d -s $SESSIONM
	
	tmux rename-window -t 0 "Bash"

	tmux new-window -t $SESSIONM:1 -n "Top"
	tmux send-keys -t "Top" "top" C-m

	tmux new-window -t $SESSIONM:2 -n "Syslog+SSH"
	tmux send-keys -t "Syslog+SSH" "tail -f /var/log/syslog" C-m
	# splits the window vertically
	# one half on top and one half on bottom
	tmux split-window -v
	tmux send-keys -t "Syslog+SSH" "tail -f /var/log/auth.log | grep sshd" C-m
	
	# Attach Session
	#tmux attach-session -t $SESSIONM
else
	printf "${warn}Session \"$SESSIONM\" already exists!${reset}\n"
fi


# Write login banner

chmod 700 ../login-banners.sh
../login-banners.sh

# update OS

chmod 700 ../osupdater.sh
../osupdater.sh

chmod 700 ../logging/install_and_setup_forwarder.sh
../logging/install_and_setup_forwarder.sh

# password policy

chmod 700 ../password-policy.sh
../password-policy.sh

printf "${info}Done!${reset}\n\n"

exit 0

