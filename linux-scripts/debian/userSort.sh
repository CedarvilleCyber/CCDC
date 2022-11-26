#!/bin/bash

# Formatting Text
info=$(tput setaf 2)
error=$(tput setaf 1)
warn=$(tput setaf 3)
reset=$(tput sgr0)

# Display a list of users that is not on debian by default

printf "\n\n${info}List of users not in nologin or false directories${reset}\n\n"
grep -vf ./dataFiles/grepUsers.data /etc/passwd
printf "\n"

# This will put onlt usernames from earlier in a file
grep -vf ./dataFiles/grepUsers.data /etc/passwd | cut -d : -f 1 > ./dataFiles/usersOutput.data

# Go through the file and print out the groups each of those users are in
LINES=$(cat ./dataFiles/usersOutput.data)
for user in $LINES; do
	printf "${info}%s${reset}\n" "$user"
	getent group | grep $user
	printf "\n"
done

printf "${warn}Look out espicially for root, adm, admin, sudo, wheel groups${reset}\n"
printf "${warn}Remove any obviously suspicious users and remove sudo priveleges from normal users${reset}\n"
printf "deluser --remove-all-files <username>\n\n"

exit 0
