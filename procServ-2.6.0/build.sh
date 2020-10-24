#!/bin/sh
set -o errexit
autoreconf -fvi
sh configure
make clean
make
mkdir -p ../cygwin_bin ../cygwin_bin64
cp -f procServ.exe ../cygwin_bin
cp -f procServ.exe ../cygwin_bin64
cp -f /usr/bin/kill.exe ../cygwin_bin/cygwin_kill.exe
cp -f /usr/bin/kill.exe ../cygwin_bin64/cygwin_kill.exe
for i in cygwin1.dll cygpath.exe; do
    cp -f /usr/bin/$i ../cygwin_bin
    cp -f /usr/bin/$i ../cygwin_bin64
done
