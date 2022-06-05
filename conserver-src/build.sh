#!/bin/sh
set -o errexit
autoreconf -fvi
sh ./configure --with-libwrap --with-openssl --with-master=conserver.nd.rl.ac.uk --with-port=782 --with-pidfile=/cygdrive/c/windows/temp/EPICS_CONSERVER.pid
make clean
make
for i in conserver/conserver.exe console/console.exe conserver.cf/samples/basic.cf; do
    cp -f $i ../cygwin/bin
done
for i in cygcrypto-1.1.dll cygcrypt-0.dll cygcrypt-2.dll cygssl-1.1.dll cygz.dll; do
    if test ! -e ../cygwin/bin/$i; then
	    echo Copying $i
		cp -f /bin/$i ../cygwin/bin
	fi
done
