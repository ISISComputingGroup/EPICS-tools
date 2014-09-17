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

In the .bat file to launch procServ you should add:

    set CYGWIN=nodosfilewarning
	
to suppress warnings about using windows style paths.

Using windows style paths in arguments to procServ is ususally OK, but if you have problems try replacing them
with cygwin syntax i.e. "/cygdrive/c/my/path" rather than "c:\my\path"

If you wish to run a .bat file rather than an executable under procServ then you should use something along the lines of:

    %ComSpec% /c runIOC.bat st.cmd

as arguments to procServ to launch your .bat file
