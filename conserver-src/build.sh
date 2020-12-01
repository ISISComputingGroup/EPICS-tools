#!/bin/sh
set -o errexit
autoreconf -fvi
sh ./configure --with-libwrap --with-openssl --with-master=conserver.nd.rl.ac.uk --with-port=782 --with-pidfile=/cygdrive/c/windows/temp/EPICS_CONSERVER.pid
make clean
make
mkdir -p ../cygwin_bin ../cygwin_bin64
for i in conserver/conserver.exe console/console.exe conserver.cf/samples/basic.cf; do
    cp -f $i ../cygwin_bin
    cp -f $i ../cygwin_bin64
done
for i in cygcrypto-1.1.dll cygssl-1.1.dll cygz.dll cygwin1.dll; do
    cp -f /usr/bin/$i ../cygwin_bin
    cp -f /usr/bin/$i ../cygwin_bin64
done
