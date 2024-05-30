setlocal
call build.bat
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
set "CYGCOPYDIR=\\isis.cclrc.ac.uk\inst$\Kits$\CompGroup\ICP\Binaries\EPICS_Tools\cygwin"
robocopy "%~dp0cygwin" "%CYGCOPYDIR%" /E /PURGE /NFL /NDL /NP /XF "rebase.db.x86_64" /R:5
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
c:\cygwin64\bin\peflags.exe --dynamicbase=0 "%CYGCOPYDIR%\bin\cygwin1.dll"
exit /b 0
