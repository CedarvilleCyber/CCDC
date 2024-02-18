#!/bin/bash
# 
# secure-os.sh
# 
# Basis OS security that can be automated
# 
# Kaicheng Ye
# Dec. 2023

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting secure-os script${reset}\n"


# environment variables
. /etc/os-release

# Package Manager
if [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "ol" ]]
then
    export PKG_MAN=yum
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]
then
    export PKG_MAN=apt-get
else
    export PKG_MAN=apt-get
    printf "${error}ERROR: Unsupported OS, assuming apt-get${reset}\n"
fi


# change file permissions
# executable only for .sh extensions.
# user only permissions except for on directories.
find ../ -type f > ./data-files/files.txt
find /home -type d -exec chmod 755 {} +
chmod 644 /etc/passwd
chmod 640 /etc/shadow
chmod 440 /etc/sudoers

# reads through each line of a file, ignoring whitespace
while IFS="" read -r f || [[ -n "$f" ]]
do
    read -r line < $f
    if [[ "$line" == "#!/bin/bash" ]]
    then
        chmod 700 $f
    elif [[ "$line" == "#!/bin/sh" ]]
    then
        chmod 700 $f
    else
        chmod 600 $f
    fi

done < ./data-files/files.txt


# remove uneccesary applications
$PKG_MAN remove nc -y
$PKG_MAN remove netcat -y
$PKG_MAN remove ncat -y

# remove uneccesary services
which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    # cups is a printing service
    # speech-dispatcher is some tts thing
    systemctl stop cups
    systemctl disable cups
    systemctl stop speech-dispatcher
    systemctl disable speech-dispatcher
else
    service cups stop
    service speech-dispatcher stop
fi

# move pre authorized keys
printf "${info}Looking for authorized_keys and moving them${reset}\n"
printf "${info}one directory up from where they were found${reset}\n"
find / -iname "authorized_keys" > ./data-files/a_keys-locations.txt 2>/dev/null

# reads through each line of a file, ignoring whitespace
while IFS="" read -r f || [[ -n "$f" ]]
do
    printf "${info}$f${reset}\n"

    mv $f `dirname $f`/../

done < ./data-files/a_keys-locations.txt


# stop php web shells
# First find all php.ini file locations
find / -iname "php.ini" > ./data-files/php-locations.txt 2>/dev/null

counter=0
# reads through each line of a file, ignoring whitespace
while IFS="" read -r f || [[ -n "$f" ]]
do
    printf "${info}$f${reset}\n"

    # create backups before writing over the file
    name=`echo $f | sed 's/\//_/g'`
    cp $f /usr/bak/$name
    ((counter++))

    # now use sed to edit the disable_functions line
    # Checks for different "states" of the "disable_functions" line
    sed -i -e '/^disable_functions.*[a-zA-Z0-9]$/ s/$/,exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork,curl_exec,curl_exec_multi/' $f
    sed -i -e '/^disable_functions.*=$/ s/$/ exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork, curl_exec, curl_exec_multi/' $f
    sed -i -e '/^disable_functions.*[a-zA-Z0-9],$/ s/$/exec,shell_exec,system,passthru,popen,proc_open,pcntl_exec,pcntl_fork,curl_exec,curl_exec_multi,/' $f
    sed -i -e '/^disable_functions.*, $/ s/$/exec, shell_exec, system, passthru, popen, proc_open, pcntl_exec, pcntl_fork, curl_exec, curl_exec_multi/' $f
done < ./data-files/php-locations.txt

# Restart apache2/httpd or nginx if we changed php
# Just try everything. No need to test one at a time
if [[ $counter -ne 0 ]]
then
    printf "${info}Restarting Web Server${reset}\n"
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
