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
find /home ! -iname "*.sh" -type f -exec chmod 600 {} +
find /home -iname "*.sh" -type f -exec chmod 700 {} +
find /home -type d -exec chmod 755 {} +
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/sudoers
chmod 444 /etc/shells

# stop php web shells
# First find all php.ini file locations
find / -iname "php.ini" > ./data-files/php-locations.txt 2>/dev/null

# reads through each line of a file, ignoring whitespace
while IFS="" read -r f || [ -n "$f" ]
do
    printf "${info}$f${reset}\n"
    sed -i -e '/^disable_functions.*[a-zA-Z0-9]$/ s/$/,exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork/' $f
    sed -i -e '/^disable_functions.*=$/ s/$/ exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork/' $f
    sed -i -e '/^disable_functions.*[a-zA-Z0-9],$/ s/$/exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork,/' $f
    sed -i -e '/^disable_functions.*, $/ s/$/exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork/' $f
done < ./data-files/php-locations.txt

# now use sed to edit the disable_functions line


exit 0
