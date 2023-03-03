#!/bin/bash

mkdir ./storage/

cp -a -r /etc/bind/ ./storage/etc-bind
cp -a -r /var/cache/bind/ ./storage/var-cache-bind

exit 0
