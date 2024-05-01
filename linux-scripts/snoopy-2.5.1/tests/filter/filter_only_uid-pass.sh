#!/bin/bash



### Configure shell and bootstrap
#
set -e
set -u
. `dirname $BASH_SOURCE`/_bootstrap.sh



### Get data
#
MY_UID=`$SNOOPY_TEST_CLI run datasource uid`
if ! $SNOOPY_TEST_CLI run filter   "only_uid"   "$MY_UID" > /dev/null; then
    snoopy_testResult_fail "My UID: $MY_UID"
else
    snoopy_testResult_pass
fi
