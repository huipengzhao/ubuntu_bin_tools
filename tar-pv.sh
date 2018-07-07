#!/bin/bash
#
# Usage:
#	tar-pv.sh <tar-file> <tar-param> [extra-tar-param]
# E.G.:
#	tar-pv.sh /my/tar/file.tar.gz xzf
#

[ $# -lt 2 ] && echo "Must give <tar-file> and <tar-param> as arguements." && exit 1

_file=$1
_param=$2
shift
shift
_extra_param=$@
bash -c "pv -pretb $_file | tar -$_param -xf - $_extra_param"
