#!/bin/bash

cp ./main.cf /etc/postfix/main.cf

cp -R ./dovecot /etc/

sed -ie "s/SUB_DOMAIN/$SUB_DOMAIN/" /etc/postfix/main.cf
sed -ie "s/DOMAIN_NAME/$DOMAIN_NAME/" /etc/postfix/main.cf


# set up users
echo >> /etc/aliases
echo "# users" >> /etc/aliases

while IFS= read -r line
do
    USER=$(echo $line | cut -d ' ' -f 1)
    PASS=$(echo $line | cut -d ' ' -f 2)
    echo "adding user: $USER"

    useradd -m $USER
    echo "$USER:$PASS" | chpasswd

    echo -e "$USER:\t\t$USER@$DOMAIN_NAME" >> /etc/aliases

    cp -R ./mail/$USER /home/$USER/Maildir
    if [[ ! -d "/home/$USER/Maildir" ]]
    then
        mkdir /home/$USER/Maildir
    fi
    chown -R $USER:$USER /home/$USER/Maildir

done < ./users.txt

newaliases

/usr/sbin/postfix start
/usr/sbin/dovecot

tail -f /var/log/lastlog
