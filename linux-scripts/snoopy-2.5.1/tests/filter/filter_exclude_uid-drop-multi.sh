#!/bin/bash



### Configure shell and bootstrap
#
set -e
set -u
. `dirname $BASH_SOURCE`/_bootstrap.sh



### Get data
#
MY_UID=`$SNOOPY_TEST_CLI run datasource uid`
MY_UID_PLUS_1=`expr $MY_UID + 1`
MY_UID_PLUS_2=`expr $MY_UID + 2`
if ! $SNOOPY_TEST_CLI run filter   "exclude_uid"   "$MY_UID_PLUS_1,$MY_UID,$MY_UID_PLUS_2" > /dev/null; then
    snoopy_testResult_pass
else
    snoopy_testResult_fail "My UID: $MY_UID"
fi
