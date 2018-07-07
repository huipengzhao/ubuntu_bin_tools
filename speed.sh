#!/bin/bash

get_size() {
	echo $(ls -l $1) | cut -d' ' -f5
}

[ -z "$1" ] && echo "Error! Need a filename!" && exit 1

f=$1

size1=$(get_size $f)
while true;
do
	sleep 1
	size2=$(get_size $f)
	delta=$(( $size2 - $size1 ))
	delta=$(( $delta / 1024 ))
	echo "Speed: $delta KBps,  Total-Size: $(( $size2 / 1024 )) KB"
	size1=$size2
done
