#!/bin/bash

. ./env.sh

cd $BASE || exit 1
./waf configure --use-external-libs --noconfirm "$@"
