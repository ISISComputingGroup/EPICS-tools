#!/bin/env sh
SCRIPT="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPTPATH=`dirname "$SCRIPT"`
#input_file="${PWD}/$1"
input_file="$1"
( cd "$SCRIPTPATH"; python input_filter.py "${input_file}" )
