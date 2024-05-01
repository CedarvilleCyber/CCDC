#!/bin/bash



### Configure shell
#
set -e
set -u



### Set test configuration
#
MY_UID=`id -u`
ARG_1="ls -la /"
ARG_2="%{cmdline}"
ARG_3="exclude_uid:$MY_UID"
ARG_4="0"
ARG_5=""



### Call/source common combined test implementation
#
. `dirname $BASH_SOURCE`/combined-generic.sh
