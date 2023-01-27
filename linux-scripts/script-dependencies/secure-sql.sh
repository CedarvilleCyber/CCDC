#!/bin/bash

$PKG_MAN install tmux -y

# ask for current and new password
printf "Please enter the current SQL root password (Enter for NONE): "
read -s curr1
echo
printf "Retype current password (Enter for NONE): "
read -s curr2
echo

# check for matching current password
while [[ "$curr1" != "$curr2" ]]
do
	printf "Passwords do not match!\n"
	printf "Enter current password (Enter for NONE): "
	read -s curr1
	echo
	printf "Retype current password (Enter for NONE): "
	read -s curr2
	echo
done

printf "Enter new password: "
read -s new1
echo
printf "Retype new password: "
read -s new2
echo

# check for matching new password
while [[ "$new1" != "$new2" ]]
do
	printf "Passwords do not match!\n"
	printf "Enter new password: "
	read -s new1
	echo
	printf "Retype new password: "
	read -s new2
	echo
done

# tmux to autmate typing

printf "Securing SQL...\n"

tmux new-session -d -s "temp"
tmux rename-window -t 0 "work"

tmux send-keys -t "work" "mysql_secure_installation" C-m
sleep 3
tmux send-keys -t "work" "$curr2" C-m
sleep 2
tmux send-keys -t "work" "Y" C-m
sleep 2
tmux send-keys -t "work" "$new2" C-m
sleep 2
tmux send-keys -t "work" "$new2" C-m
sleep 2
tmux send-keys -t "work" "Y" C-m
sleep 2
tmux send-keys -t "work" "Y" C-m
sleep 2
tmux send-keys -t "work" "Y" C-m
sleep 2
tmux send-keys -t "work" "Y" C-m
sleep 2

printf "Done!\n"

tmux kill-session -t "temp"

exit 0
