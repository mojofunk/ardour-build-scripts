#!/bin/bash

. ./env.sh

cd $BASE || exit 1
./waf configure $COMMON_OPTS $TEST_OPTS $TEST_BACKENDS --gtk-disable-deprecated "$@"
