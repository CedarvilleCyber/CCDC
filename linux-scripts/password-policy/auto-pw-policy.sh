#!/bin/bash

clear

source /etc/os-release

# Set the distribution-dependent config file
case $ID in
    "debian"|"ubuntu")
        ;;
    "fedora"|"centos")
        ;;
esac

# Set the distribution-independent config file

exit 0
