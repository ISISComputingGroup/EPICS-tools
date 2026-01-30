setlocal
call %~dp0start_cygserver.bat c:\cygwin64
call %~dp0build.bat
set errcode=%ERRORLEVEL%
call %~dp0stop_cygserver.bat c:\cygwin64
if %errcode% NEQ 0 exit /b %errcode%
set "CYGCOPYDIR=\\isis.cclrc.ac.uk\inst$\Kits$\CompGroup\ICP\Binaries\EPICS_Tools\cygwin"
robocopy "%~dp0cygwin" "%CYGCOPYDIR%" /E /PURGE /NFL /NDL /NP /XF "rebase.db.x86_64" /R:5 /log:"%~dp0cyg_copy.log"
if %ERRORLEVEL% GEQ 4 exit /b %ERRORLEVEL%
c:\cygwin64\bin\peflags.exe --dynamicbase=0 "%CYGCOPYDIR%\bin\cygwin1.dll"
exit /b 0
