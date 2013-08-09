#!/bin/bash

. ./env.sh

cd $BASE || exit 1
./waf "$@"
