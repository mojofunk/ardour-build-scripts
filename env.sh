#!/bin/bash

BASE=$(readlink -f $0)
BASE=$(dirname $BASE) # up one
BASE=$(dirname $BASE) # up one more
BASE=$BASE/ardour

BUILD_DIR=$BASE/build

COMMON_OPTS="--noconfirm --use-external-libs"
TEST_OPTS="--test --single-tests"
