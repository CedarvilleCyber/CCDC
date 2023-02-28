#!/bin/bash

cp -r /etc/bind/ ./backups/etc-bind
cp -r /var/cache/bind/ ./backups/var-cache-bind

exit 0
