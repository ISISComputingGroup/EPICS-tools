set OLDDIR=%CD%
cd %~dp0
python input_filter.py %1
set myerr=%ERRORLEVEL%
cd %OLDDIR%
exit /b %myerr%
