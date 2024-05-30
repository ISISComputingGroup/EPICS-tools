To build you will need two cygwin installations: 
* A full installation with compilers in c:\cygwin64 to do the actual build
* A bare minimum installation in c:\mini_cygwin64 for deployment
These two installations should be the same version, so update them at the same time.
You'll need to run the cygwin updater twice giving the two directories. 

* Running build.bat
A copy of c:\mini_cygwin64 is made into a local "tool/master/cygwin" directory, then
procServ and conserver are built and installed here.

* Running jenkins_build.bat
This calls build.bat then the resulting directory tree is
copied to kits$ where create_icp_binaries can pick it up from
This file should only be run from Jenkins

Note that as mini_cygwin64 is copied it will have "noacl" added to /etc/fstab in as part
of the copy - this is to avoid permission problems. The line will look like:

    none /cygdrive cygdrive binary,noacl,posix=0,user 0 0

you do not need to do this in your own cygwin installations.
The only local change you need to do is disable ASLR on your main cygwin installation.
To do this run   disable_aslr.bat    if you get errors runing this, you may need to rerun as
an administrator. You only need to run this if you update cygwin1.dll - when build.bat
is run it will check and tell you if you need to run it
