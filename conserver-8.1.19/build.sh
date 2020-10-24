#!/bin/sh
autoreconf -fvi
sh ./configure --with-libwrap --with-openssl --with-master=conserver.nd.rl.ac.uk --with-port=782 --with-pidfile=/cygdrive/c/windows/temp/EPICS_CONSERVER.pid
make clean
make
cp -f conserver/conserver.exe ../cygwin_bin
cp -f conserver/conserver.exe ../cygwin_bin64
cp -f console/console.exe ../cygwin_bin
cp -f console/console.exe ../cygwin_bin64
cp -f conserver.cf/samples/basic.cf ../cygwin_bin
cp -f conserver.cf/samples/basic.cf ../cygwin_bin64
