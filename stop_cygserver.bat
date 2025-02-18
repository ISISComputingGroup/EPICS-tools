@echo off
setlocal
@echo %DATE% %TIME% stopping cygserver
set "PATH=%~dp0cygwin\bin;%PATH%"
for /f %%i in ( 'tasklist /fi  "IMAGENAME eq cygserver.exe"' ) do set PROC=%%i
if "%PROC%" == "cygserver.exe" (
    REM only do this if cygserver is running as it can take a while if there are site ldap issues
    %~dp0cygwin\usr\sbin\cygserver.exe --shutdown 
    REM wait a bit and kill if shutdown not complete
    ping -n 5 127.0.0.1 >NUL
    taskkill /f /im cygserver.exe 2>NUL
) else (
    @echo %DATE% %TIME% cygserver is not running
)
