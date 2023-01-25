To build you will need two cygwin installations: 
* A full installation with compilers in c:\cygwin64 to do the actual build
* A bare minimum installation in c:\mini_cygwin64 for deployment
These two installations should be the same version, so update them at the same time

A copy of c:\mini_cygwin64 is made into a local "cygwin" directory, then
procServ and conserver are built and installed here, then the resulting
directory tree is copied to kits$ where create_icp_binaries can pick it up from

Note that /etc/fstab in mini_cygwin64 should have "noacl" added - this is to
avoid permission problems. The line should look like:

    none /cygdrive cygdrive binary,noacl,posix=0,user 0 0

Do this only in mini_cygwin64 and not the cygwin64 main build
