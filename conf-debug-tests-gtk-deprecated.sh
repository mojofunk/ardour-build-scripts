#!/bin/bash

. ./env.sh

cd $BASE || exit 1
./waf configure $COMMON_OPTS $TEST_OPTS --with-backends=dummy,jack --gtk-disable-deprecated "$@"
