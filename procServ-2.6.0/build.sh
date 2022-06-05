#!/bin/sh
set -o errexit
autoreconf -fvi
sh configure
make clean
make
cp -f procServ.exe ../cygwin/bin
