setlocal
cd procServ-2.6.0
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
cd ..\conserver-src
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
cd ..
robocopy "cygwin_bin" "\\isis.cclrc.ac.uk\inst$\Kits$\CompGroup\ICP\EPICS_Tools\cygwin_bin" /E /PURGE /NFL /NDL /NP
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
robocopy "cygwin_bin64" "\\isis.cclrc.ac.uk\inst$\Kits$\CompGroup\ICP\EPICS_Tools\cygwin_bin64" /E /PURGE /NFL /NDL /NP
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
exit /b 0
