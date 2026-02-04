@echo off
setlocal
if "%1" == "" (
    set "MYCYGHOME=%~dp0cygwin"
) else (
    set "MYCYGHOME=%1"
)
@echo %DATE% %TIME% starting cygserver from %MYCYGHOME%
set "PATH=%MYCYGHOME%\bin;%PATH%"
for /f %%i in ( 'tasklist /fi  "IMAGENAME eq cygserver.exe"' ) do set PROC=%%i
if "%PROC%" == "cygserver.exe" (
    @echo %DATE% %TIME% cygserver is already running
    exit /b 0
)
if not exist "%MYCYGHOME%\etc\cygserver.conf" (
    copy %MYCYGHOME%\etc\defaults\etc\cygserver.conf %MYCYGHOME%\etc\cygserver.conf
)
if not exist "C:\Instrument\Var\logs\ibex_server" mkdir C:\Instrument\Var\logs\ibex_server
powershell -Command "Start-Process cmd -Args /c,\"%MYCYGHOME%\usr\sbin\cygserver.exe --stderr --no-syslog\" -RSE C:\Instrument\Var\logs\ibex_server\cygserver_err.log -RSO C:\Instrument\Var\logs\ibex_server\cygserver_out.log -WindowStyle Hidden"
REM we started using cygserver due to a site ldap issue - seems to need at least 45 seconds
REM to do and cache this lookup
@echo %DATE% %TIME% waiting 60 seconds for cygserver to complete setup
waitfor /t 60 WillNeverHappen >NUL 2>&1
tasklist /fi  "IMAGENAME eq cygserver.exe"
