#!/bin/sh
# 
# secure-os.sh
# 
# Basis OS security that can be automated
# 
# Kaicheng Ye
# Dec. 2023

if [ "$(id -u)" != "0" ]; then
        printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
        exit 1
fi

printf "${info}Starting secure-os script${reset}\n"

# change file permissions
chmod -R 700 /home/*
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/sudoers
chmod 444 /etc/shells

# stop php web shells
# First find all php.ini file locations
find / -iname "php.ini" > ./data-files/php-locations.txt 2>/dev/null

# now use sed to edit the disable_functions line


exit 0
