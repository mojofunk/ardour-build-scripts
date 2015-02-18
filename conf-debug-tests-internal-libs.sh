#!/bin/bash

. ./env.sh

cd $BASE || exit 1
./waf configure --noconfirm $TEST_OPTS "$@"
