#!/bin/bash

# using ufw
# close all ports except for neccessary ones
# even internet is closed!
# start internet back up by opening https, http
# ntp should be fine and dns should be fine

apt-get purge ufw -y
apt-get install ufw -y

ufw default deny outgoing
ufw default deny incoming

ufw allow in dns
ufw allow out dns
ufw allow in ntp
ufw allow out ntp

ufw enable

exit 0
