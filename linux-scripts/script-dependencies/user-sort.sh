#!/bin/bash
# 
# user-sort.sh
#
# See which users can login on the machine
# For those users, see groups and sudo priviledges
#
# Kaicheng Ye
# Jan. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting user-sort script${reset}\n"

# first remove old file if exists
rm -rf ../data-files/users-output.txt

# Get enabled users that have a login shell
grep -vf ./grep-users.txt /etc/passwd | cut -d : -f 1 > ../data-files/users-tmp.txt
while IFS="" read -r name || [[ -n "$name" ]]
do
    # sort out the accounts that are enabled
    awk -v name="$name" -F ':' '$1 ~ name && $2 !~ "\*" {print $1}' /etc/shadow >> ../data-files/users-output.txt
done < ../data-files/users-tmp.txt
rm -rf ../data-files/users-tmp.txt

# Display a list of users that have a login shell
printf "\n\n${info}List of users not in nologin or false directories${reset}\n\n"
cat ../data-files/users-output.txt
printf "\n"

# Go through the file and print out the groups each of those users are in
LINES=$(cat ../data-files/users-output.txt)
for user in $LINES; do
	printf "${info}$user${reset}\n"
	getent group | grep $user
	printf "\n"
done
printf "${warn}Look out espicially for root, adm, admin, sudo, wheel groups${reset}\n\n"

# Now show the sudoers file without comments
printf "${info}Check for suspicious priviledges in /etc/sudoers${reset}\n"
printf "${info}Showing the file without comments. Edit with 'visudo'${reset}\n"
cat /etc/sudoers | grep ^[^#]

printf "\n\n${warn}Remove any obviously suspicious users and remove sudo priveleges from normal users${reset}\n"
printf "deluser --remove-all-files <username>\n\n"

exit 0
