#!/bin/bash

# Master antivirus setup script for linux (CCDC 2023)
# Installs clamav and updates signature database
#
# Notes:
# - Script assumes that PKG_MAN environment variable exists

if [[ $(id -u) != "0" ]]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

echo "Begin setup-antivirus ..."

# Install clamav and clamav-daemon
$PKG_MAN install clamav clamav-daemon -y

# Stop freshclam service
systemctl stop clamav-freshclam

# Run freshclam to update the signature database
freshclam

# Start freshclam service
systemctl start clamav-freshclam

echo "... setup-antivirus complete!"
