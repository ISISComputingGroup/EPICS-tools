To build you will need two cygwin installations: 
* A full installation with compilers in c:\cygwin64 to do the actual build
* A bare minimum installation in c:\mini_cygwin64 for deployment
These two installations should be the same version, so update them at the same time

* Running build.bat
A copy of c:\mini_cygwin64 is made into a local "cygwin" directory, then
procServ and conserver are built and installed here.

* Running jenkins_build.bat
This calls build.bat then the resulting directory tree is
copied to kits$ where create_icp_binaries can pick it up from

Note that /etc/fstab in mini_cygwin64 will have "noacl" added as part
of the copy - this is to avoid permission problems. The line will look like:

    none /cygdrive cygdrive binary,noacl,posix=0,user 0 0

(do not do this in the cygwin64 main build)
