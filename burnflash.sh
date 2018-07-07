#!/bin/bash
#
# The env OUT must be defined.
#

REBOOT="yes"
if [ "$1" = "-n" ] ; then
	REBOOT="no"
	shift
fi

echo "outdir: $OUT"

adb reboot bootloader
for img in $@
do
	echo "fastboot flash $img ..."
	case $img in
	boot)
		fastboot flash boot $OUT/boot.img
		;;
	cache)
		fastboot flash cache $OUT/cache.img
		;;
	system)
		fastboot flash system $OUT/system.img
		;;
	system-w)
		fastboot -w flash system $OUT/system.img
		;;
	system_other)
		fastboot flash system_b $OUT/system_other.img
		;;
	userdata)
		fastboot flash userdata $OUT/userdata.img
		;;
	vendor)
		fastboot flash vendor $OUT/vendor.img
		;;
	vbmeta)
		fastboot flash vbmeta $OUT/vbmeta.img
		;;
	esac
done
echo "done."

[ "$REBOOT" = "yes" ] && fastboot reboot
