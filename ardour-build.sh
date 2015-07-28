#!/bin/bash

BASE=$(readlink -f $0)
BASE=$(dirname $BASE) # up one
BASE=$(dirname $BASE) # up one more
BASE=$BASE/ardour

ARDOUR_SRC_DIR=${ARDOUR_SRC_DIR:=$BASE}

cd $ARDOUR_SRC_DIR || exit 1

ARDOUR_BRANCH=`git rev-parse --abbrev-ref HEAD`

cd - || exit 1

COMMON_OPTS="--noconfirm --use-external-libs"
TEST_OPTS="--test --single-tests"
TEST_BACKENDS="--with-backends=jack,dummy,alsa"

declare -A config
config["debug"]="$COMMON_OPTS"
config["debug-internal-libs"]="--noconfirm"
config["debug-nojack"]="$COMMON_OPTS --with-backend=dummy,alsa"
config["debug-gtk-deprecated"]="$COMMON_OPTS --gtk-disable-deprecated"
config["debug-tests"]="$COMMON_OPTS $TEST_OPTS $TEST_BACKENDS"
config["debug-tests-cxx11"]="$COMMON_OPTS $TEST_OPTS $TEST_BACKENDS --cxx11"
config["debug-tests-amalgamated"]="$COMMON_OPTS $TEST_OPTS $TEST_BACKENDS --enable-amalgamation"
config["release"]="$COMMON_OPTS --optimize"

function print_usage ()
{
	echo "usage: ardour-build [-l] [-h] <command> <config>"
	echo " "
	echo "The commands are:"
	echo "    configure"
	echo "    build"
	echo "    install"
	echo "    clean"
}

function print_configs ()
{
	echo "Possible build configurations: "
	echo "${!config[@]}"
}

OPTIND=1
while getopts "h?vl" opt; do
	case "$opt" in
		h)
			print_usage
			exit 0
			;;
		v)
			ARDOUR_BUILD_VERBOSE=1
			set -x
			;;
		l)
			print_configs
			exit 0
			;;
	esac
done
shift "$((OPTIND-1))"

if [ -z "$1" ] || [ -z "$2" ]; then
		print_usage
		echo "You must specify command and build config"
		exit 1
fi

ARDOUR_BUILD_COMMAND="$1"
ARDOUR_BUILD_CONFIG="$2"
ARDOUR_BUILD_SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
ARDOUR_BUILD_ROOT="$ARDOUR_BUILD_SCRIPT_PATH/BUILD"

CONFIG_BUILD_DIR="$ARDOUR_BUILD_ROOT/$ARDOUR_BRANCH-$ARDOUR_BUILD_CONFIG"
CONFIG_WAF_BUILD_DIR="$CONFIG_BUILD_DIR/build"

mkdir -p $ARDOUR_BUILD_ROOT || exit 1

function sync ()
{
	rsync -av $ARDOUR_SRC_DIR/ $CONFIG_BUILD_DIR || exit 1
}

function configure ()
{
	sync
	cd $CONFIG_BUILD_DIR || exit 1
	./waf configure ${config["$ARDOUR_BUILD_CONFIG"]} "$@"
}

function build ()
{
	sync
	cd $CONFIG_BUILD_DIR || exit 1
	./waf "$@"
}

function install ()
{
	sync
	cd $CONFIG_BUILD_DIR || exit 1
	./waf install "$@"
}

function clean ()
{
	cd $CONFIG_BUILD_DIR || exit 1
	rm -rf $CONFIG_WAF_BUILD_DIR
}

if [ "${config["$ARDOUR_BUILD_CONFIG"]+isset}" ]; then
	echo "Using configuration: $ARDOUR_BUILD_CONFIG"
else
	echo "No such configuration: $ARDOUR_BUILD_CONFIG"
	print_configs
	exit 1
fi;

case $ARDOUR_BUILD_COMMAND in
	configure)
		configure || exit 1
		;;
	build)
		build || exit 1
		;;
	install)
		install || exit 1
		;;
	clean)
		clean || exit 1
		;;
	*)
		print_usage
		exit 1
		;;
esac