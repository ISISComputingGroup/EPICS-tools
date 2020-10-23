setlocal
cd procServ-2.6.0
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
cd ..\conserver-8.1.19
for /F "usebackq" %%I in (`c:\cygwin64\bin\cygpath --absolute .`) do SET CURRENT=%%I
c:\cygwin64\bin\bash.exe --login -c "cd %CURRENT%; sh build.sh"
robocopy "cygwin_bin" "\\isis\inst$\Kits$\CompGroup\ICP\EPICS_Tools\cygwin_bin" /E /PURGE
robocopy "cygwin_bin64" "\\isis\inst$\Kits$\CompGroup\ICP\EPICS_Tools\cygwin_bin64" /E /PURGE
