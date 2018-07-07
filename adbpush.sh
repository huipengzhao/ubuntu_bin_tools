#!/bin/bash
#
# The env OUT must be defined.
#

T=${ANDROID_BUILD_TOP}

prefix=${OUT}

ADB='adb wait-for-device'

######################################## Main ##########

REBOOT="yes"
if [ "$1" = "-n" ] ; then
	REBOOT="no"
	shift
	echo "no reboot"
fi

pkgs=$@

echo "==> adb root"
${ADB} root

sleep 0.2

echo "==> adb remount"
${ADB} remount

if [ $? -ne 0 ] ; then
	echo "Error! adb remount failed, quit."
	exit 1
fi

for p in $pkgs
do
	p=${p##${T}/}
	p=${T}/${p}
	if [ ${p:0:${#prefix}} != ${prefix} ] ; then
		echo "WARNING: ${p} is an invalid path, ignored."
		echo "         prefix should be ${prefix}"
		continue
	fi
	echo "==> adb push $p ${p#${prefix}}"
	${ADB} push $p ${p#${prefix}}
done

${ADB} shell sync

if [ "$REBOOT" = "yes" ] ; then
	echo "==> adb reboot"
	${ADB} reboot
fi
