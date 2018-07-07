#!/bin/bash
#
# This script list all compiled files and related headers.
#
# Usage:
#   ls_kernel.sh [obj-dir] [src-dir]
#


#
# Convert related path to absolute path.
#
abspath() { # file or dir
	if [ -d ${1} ] ; then
		echo "$(cd ${1}; pwd)"
	else
		echo "$(cd $(dirname ${1}); pwd)/$(basename ${1})"
	fi
}

#
# If some paths have './' or '../', then help to get the real path.
#
realpaths() { # tmp_file.lst
	rm -f ${1}.realpath
	bad_paths=$(grep '\.\.\/' ${1})
	if [ ! -z "${bad_paths}" ] ; then
		for p in ${bad_paths}; do
			ap=$(abspath $p)
			echo ${ap/${__SRC_DIR}/} >> ${1}.realpath
		done
		grep -v '\.\.\/' ${1} >> ${1}.realpath
	else
		cp ${1} ${1}.realpath
	fi
	sort -u ${1}.realpath > ${1} # sort and unique each header file.
	rm -f ${1}.realpath
	# now all '../' paths are handled. we start to handle './' ones.
	bad_paths=$(grep '\.\/' ${1})
	if [ ! -z "${bad_paths}" ] ; then
		for p in ${bad_paths}; do
			ap=$(abspath $p)
			echo ${ap/${__SRC_DIR}/} >> ${1}.realpath
		done
		grep -v '\.\/' ${1} >> ${1}.realpath
	else
		cp ${1} ${1}.realpath
	fi
	sort -u ${1}.realpath > ${1} # sort and unique each header file.
	rm -f ${1}.realpath
}


TMP_FILES=/tmp/compiled_files.txt
TMP_HEADS=/tmp/compiled_heads.txt
rm -f ${TMP_FILES} ${TMP_FILES}.unsorted
rm -f ${TMP_HEADS} ${TMP_HEADS}.unsorted

OBJ_DIR=$1
[ -z $OBJ_DIR ] && OBJ_DIR="."
SRC_DIR=$2
[ -z $SRC_DIR ] && SRC_DIR=$OBJ_DIR

if [ ! -d $OBJ_DIR ] ; then
	echo "Error: $OBJ_DIR is not a directory"
	exit 1
fi
if [ ! -d $SRC_DIR ] ; then
	echo "Error: $SRC_DIR is not a directory"
	exit 1
fi
cd $OBJ_DIR && OBJ_DIR=`pwd` && cd - >/dev/null
cd $SRC_DIR && SRC_DIR=`pwd` && cd - >/dev/null

_SRC_DIR="${SRC_DIR}/"
__SRC_DIR=${_SRC_DIR//\//\\\/}

#
# List all .o files excluding ./scripts directory.
#
cd $OBJ_DIR
objs=`find . -path "./scripts" -prune -o -name "*.o" -type f -print | grep -v 'built-in'`


#
# List all .c/.s/.S files
#
cd $SRC_DIR
for f in $objs
do
	c=${f%%.o}.c
	[ -f $c ] && echo $c >> ${TMP_FILES}
	s=${f%%.o}.s
	[ -f $s ] && echo $s >> ${TMP_FILES}
	S=${f%%.o}.S
	[ -f $S ] && echo $S >> ${TMP_FILES}
done
# if some .c files include other .c files, we find the included ones.
cat ${TMP_FILES} |xargs egrep -H "[[:space:]]*include[[:space:]]+\".*\.c\"" |sed 's/\"//g;s/[^/]\+ //g' >${TMP_FILES}.unsorted
cat ${TMP_FILES} >> ${TMP_FILES}.unsorted
sed -i "s/${__SRC_DIR}//g" ${TMP_FILES}.unsorted
sort -u ${TMP_FILES}.unsorted > ${TMP_FILES}
realpaths ${TMP_FILES}


#
# List headers
#
rm -f ${TMP_HEADS}
rm -f ${TMP_HEADS}.unsorted
cmd_lst=$(find ${OBJ_DIR} -path "${OBJ_DIR}/scripts" -prune -o -name "*.o.cmd" -type f -print)
for cmd in $cmd_lst; do
	egrep '[[:space:]]+.*\.h \\' $cmd | grep -v '\$(wildcard' >> ${TMP_HEADS}.unsorted
done
sed -i "s/${__SRC_DIR}//g" ${TMP_HEADS}.unsorted
sort -u ${TMP_HEADS}.unsorted > ${TMP_HEADS}
sed -i 's/^ *//g' ${TMP_HEADS} # remove the starting 2 spaces.
sed -i 's/ \\$//g' ${TMP_HEADS} # remove the ending 2 chars.
rm -f ${TMP_HEADS}.unsorted
realpaths ${TMP_HEADS}


#
# Final output
#
egrep '\<generated\>' $TMP_HEADS
egrep -v '\<generated\>' $TMP_HEADS
sed 's/^\.\///g' $TMP_FILES
