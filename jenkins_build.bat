setlocal
REM this is a minimal cygwin install used at ibex runtime
REM we install procServ and conserver into this directory
robocopy "c:\mini_cygwin64" "%~dp0cygwin" /E /PURGE /NFL /NDL /NP /XF "rebase.db.x86_64" /XD "c:\mini_cygwin64\home\gamekeeper" /R:5
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
REM disable ASLR for cygwin DLL
c:\cygwin64\bin\bash.exe --login -c "peflags --dynamicbase=0 `cygpath --absolute '%~dp0cygwin\bin\cygwin1.dll'`"
"%~dp0build_utils\sed.exe" -i -e "s/^none \/cygdrive.*/none \/cygdrive cygdrive binary,noacl,posix=0,user 0 0/" "%~dp0cygwin\etc\fstab"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
REM the full cygwin with compiler packages is in c:\cygwin64
cd procServ-2.6.0
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
cd ..\conserver-src
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
cd ..
robocopy "%~dp0cygwin" "\\isis.cclrc.ac.uk\inst$\Kits$\CompGroup\ICP\Binaries\EPICS_Tools\cygwin" /E /PURGE /NFL /NDL /NP /XF "rebase.db.x86_64" /R:5
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
exit /b 0
