#!/bin/bash
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
# executable only for .sh extensions.
# user only permissions except for on directories.
find /home ! -iname "*.sh" -type f -exec chmod 600 {} +
find /home -iname "*.sh" -type f -exec chmod 700 {} +
find /home -type d -exec chmod 755 {} +
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/sudoers
chmod 444 /etc/shells


# remove uneccesary applications
$PKG_MAN remove nc
$PKG_MAN remove netcat
$PKG_MAN remove ncat

# remove uneccesary services
which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    # cups is a printing service
    systemctl stop cups
    systemctl disable cups
else
    service cups stop
fi


# stop php web shells
# First find all php.ini file locations
find / -iname "php.ini" > ./data-files/php-locations.txt 2>/dev/null

counter=0
# reads through each line of a file, ignoring whitespace
while IFS="" read -r f || [ -n "$f" ]
do
    printf "${info}$f${reset}\n"

    # create backups before writing over the file
    cp $f /opt/bak/${counter}php.ini
    ((counter++))

    # now use sed to edit the disable_functions line
    # Checks for different "states" of the "disable_functions" line
    sed -i -e '/^disable_functions.*[a-zA-Z0-9]$/ s/$/,exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork/' $f
    sed -i -e '/^disable_functions.*=$/ s/$/ exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork/' $f
    sed -i -e '/^disable_functions.*[a-zA-Z0-9],$/ s/$/exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork,/' $f
    sed -i -e '/^disable_functions.*, $/ s/$/exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork/' $f
done < ./data-files/php-locations.txt

# Restart apache2/httpd or nginx if we changed php
# Just try everything. No need to test one at a time
if [[ $counter -ne 0 ]]
then
    which systemctl >/dev/null
    if [[ $? -eq 0 ]]
    then
        systemctl restart apache2
        systemctl restart httpd
        systemctl restart nginx
    else
        service apache2 restart
        service httpd restart
        service nginx restart
    fi
fi

exit 0
