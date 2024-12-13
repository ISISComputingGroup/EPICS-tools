Building
--------

In general:

    sh configure
	make
	
should be enough. If you have autoconf and automake packages, then for a really
clean build type:

    autoreconf -fvi
    sh configure
    make clean
    make

If you plan to control procServ from a non-localhost address, you will need to use:

	sh configure --enable-access-from-anywhere

in place of "sh configure" above

Running on Win32
----------------

In the .bat file to launch procServ you may wish to add:

    set CYGWIN=disable_pcon

this disables cygwin support for windows pseudoconsoles. In some cases, such as when using the
console/conserver system to connect to procServ, restarting an IOC while connected caused all
the output to be forced to 80 columns and ansi control sequences to appear in log files.

Using windows style paths in arguments to procServ is ususally OK, but if you have problems try replacing them
with cygwin syntax i.e. "/cygdrive/c/my/path" rather than "c:\my\path"

If you wish to run a .bat file rather than an executable under procServ then you should use something along the lines of:

    %ComSpec% /c runIOC.bat st.cmd

as arguments to procServ to launch your .bat file
