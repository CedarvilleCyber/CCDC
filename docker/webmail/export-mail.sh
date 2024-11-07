#!/bin/bash

rm -rf ./copied-mail
mkdir ./copied-mail
cd ./copied-mail

for entry in /home/*
do
    USER=$(basename $entry)
    cp -R /home/$USER/Maildir/ ./$USER
done

cd ../

read -p "WORKSTATION's IP: " IP
scp -r ./copied-mail sysadmin@$IP:/home/sysadmin/

exit 0
