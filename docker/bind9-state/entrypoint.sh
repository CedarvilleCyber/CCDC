#!/bin/bash

chown -R bind:bind /etc/bind
chown -R bind:bind /var/cache/bind
chown -R bind:bind /var/lib/bind
chown -R bind:bind /var/log/bind

chmod 775 /run/named

exec "$@"