@echo off
setlocal
REM disable ASLR in cygwin DLL to avoid fork issues in compile
set MYCYG=c:\cygwin64
if not "%1" == "" (
    set "MYCYG=%1"
)
@echo Disabling ASLR on %MYCYG%\bin\cygwin1.dll
copy /y "%MYCYG%\bin\cygwin1.dll" "%~dp0cygwin1-nodb.dll"
"%MYCYG%\bin\peflags.exe" --dynamicbase=0 "%~dp0cygwin1-nodb.dll"
copy /y "%~dp0cygwin1-nodb.dll" "%MYCYG%\bin\cygwin1.dll"
set errcode=%ERRORLEVEL%
del "%~dp0cygwin1-nodb.dll"
if %errcode% NEQ 0 (
    @echo ***
    @echo *** Error disabling ASLR on %MYCYG%\bin\cygwin1.dll ***
    @echo ***
    exit /b %errcode%
)
@echo.
@echo *** All OK ***
@echo.
