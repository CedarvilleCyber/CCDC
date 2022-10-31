#!/bin/bash

awk -F ":" '{print $1}' | \
while read username; do
if["$username"]; then
useradd -m -s/bin/bash $username
chmod 0700 /home/"$username"
fi
done

