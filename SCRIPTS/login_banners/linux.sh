#!/bin/bash

if (which yum)
then
  echo "###############################" > /etc/motd
  echo "## This system may not be    ##" >> /etc/motd
  echo "## accessed without proper   ##" >> /etc/motd
  echo "## authorization. There is   ##" >> /etc/motd
  echo "## no reasonable expectation ##" >> /etc/motd
  echo "## of privacy. Thank you.    ##" >> /etc/motd
  echo "###############################" >> /etc/motd
fi
  
if (which apt-get)
then
  # Do y'all's thing
fi
