#!/bin/sh
set -o errexit
autoreconf -fvi
sh configure
make clean
make
mkdir -p ../cygwin_bin ../cygwin_bin64
cp -f procServ.exe ../cygwin_bin
cp -f procServ.exe ../cygwin_bin64
# these are used for managing process and PID file 
for i in kill.exe rm.exe ps.exe; do
    cp -f /usr/bin/$i ../cygwin_bin/cygwin_$i
    cp -f /usr/bin/$i ../cygwin_bin64/cygwin_$i
done
# cygintl-8.dll is needed by rm.exe
for i in cygwin1.dll cygintl-8.dll cygpath.exe; do
    cp -f /usr/bin/$i ../cygwin_bin
    cp -f /usr/bin/$i ../cygwin_bin64
done
