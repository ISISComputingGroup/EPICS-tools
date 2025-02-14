@echo off
setlocal
@echo %DATE% %TIME% starting cygserver
set "PATH=%~dp0cygwin\bin;%PATH%"
for /f %%i in ( 'tasklist /fi  "IMAGENAME eq cygserver.exe"' ) do set PROC=%%i
if "%PROC%" == "cygserver.exe" (
    @echo %DATE% %TIME% cygserver is already running
    exit /b 0
)
if not exist "%~dp0cygwin\etc\cygserver.conf" (
    copy %~dp0cygwin\etc\defaults\etc\cygserver.conf %~dp0cygwin\etc\cygserver.conf
)
powershell -Command "Start-Process cmd -Args /c,\"%~dp0cygwin\usr\sbin\cygserver.exe --stderr --no-syslog\" -RSE C:\Instrument\Var\logs\ibex_server\cygserver_err.log -RSO C:\Instrument\Var\logs\ibex_server\cygserver_out.log -WindowStyle Hidden"
