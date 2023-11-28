#!/bin/sh
set -o errexit
autoreconf -fvi || autoreconf -fvi || autoreconf -fvi
CONF_ARGS="--with-libwrap --with-openssl --with-master=conserver.nd.rl.ac.uk --with-port=782 --with-pidfile=/cygdrive/c/windows/temp/EPICS_CONSERVER.pid"
sh ./configure $CONF_ARGS || sh ./configure $CONF_ARGS
make clean || make clean
make || make
for i in conserver/conserver.exe console/console.exe conserver.cf/samples/basic.cf; do
    cp -f $i ../cygwin/bin
done
for i in cygcrypto-3.dll cygcrypt-0.dll cygcrypt-2.dll cygssl-3.dll cygz.dll cygwrap-0.dll; do
    if test ! -e ../cygwin/bin/$i; then
	    echo Copying $i
		cp -f /bin/$i ../cygwin/bin
	fi
done
