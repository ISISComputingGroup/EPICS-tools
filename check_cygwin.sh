#!/bin/sh

# check we have ASLR disabled as that can cause fork() issues
if test `peflags -d /bin/cygwin1.dll | grep '\-dynamicbase' | wc -l` -eq 1; then
    exit 0
else
    echo ERROR: cygwin1.dll has dynamicbase enabled
    echo ERROR: please run     peflags -d0    on this file to disable
    exit 1
fi
