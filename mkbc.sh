#!/bin/bash
#
# Usage: mkbc.sh <dest-dir>
#

ADB="adb wait-for-device"
LOGROOT=/data/bootchart
TARBALL=bootchart.tgz
#FILES="header proc_stat.log proc_ps.log proc_diskstats.log kernel_pacct"
FILES="header proc_stat.log proc_ps.log proc_diskstats.log"

DESTDIR="$1"

if [ -z "$DESTDIR" ] ; then
    echo "Must give a directory to save the logs and bootchart.png!"
    exit 1
fi

# mkdir
rm -rf $DESTDIR
mkdir -p $DESTDIR
cd $DESTDIR
if [ $? -ne 0 ] ; then
    echo "mkdir -p $DESTDIR failed!"
    exit 1
fi

# adb pull logs into current dir
$ADB root
for f in $FILES; do
    $ADB pull $LOGROOT/$f ./ 2>&1
    [ $? -ne 0 ] && exit 1
done

# pack the dir
tar -czf $TARBALL $FILES

# generate the bootchart.png
java -jar /work/bin/bootchart.jar -o ./ $TARBALL

# show the bootchart.png
eog bootchart.png &

# fetch the logs
$ADB logcat -v threadtime -d > logcat.log
$ADB shell dmesg > dmesg.log

# get back (not necessary)
cd -
