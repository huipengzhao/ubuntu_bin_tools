#!/bin/bash

ARGS=
ARGS+=" "ZZZ:D

if [ "$1" = "d" ] ; then
	ARGS=" -d "+$ARGS
	shift
fi

if [ "$1" != "v" ] ; then
	ARGS+=" art:S dex2oat:S"
else
	shift
fi

if [ "$1" = "b" ] ; then
	ARGS+=" Zygote:D SystemServer:W PackageManager:D System:D AndroidRuntime:D"
	shift
fi

set -x
adb logcat -v threadtime -s ${ARGS} $@
