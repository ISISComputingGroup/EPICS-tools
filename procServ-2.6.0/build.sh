#!/bin/sh
set -o errexit
autoreconf -fvi || autoreconf -fvi || autoreconf -fvi
sh configure || sh configure || sh configure
make clean || make clean
make || make
cp -f procServ.exe ../cygwin/bin
