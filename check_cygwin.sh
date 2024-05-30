#!/bin/sh
set -o errexit

# check we have ASLR disabled as that can cause fork() issues
if test `peflags -d /bin/cygwin1.dll | grep '\-dynamicbase' | wc -l` -eq 1; then
    exit 0
else
    echo ERROR: cygwin1.dll has dynamicbase enabled
    echo ERROR: please run    disable_aslr.bat   with all cygwin windows closed
    echo ERROR: you may need to do this from an adminitrator prompt
    exit 1
fi
