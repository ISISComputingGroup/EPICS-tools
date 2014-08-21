@echo off
set MYDIR=%~dp0
rem set OLDDIR=%CD%
set PATH=C:\Program Files\Java\jre7\bin;C:\Program Files (x86)\Java\jre7\bin;%PATH%
rem cd /d %MYDIR%..\VisualDCT-dist-2.6.1274\2.6.1274
java -cp %MYDIR%..\VisualDCT-dist-2.6.1274\2.6.1274\VisualDCT.jar -DEPICS_DB_INCLUDE_PATH=%EPICS_DB_INCLUDE_PATH% com.cosylab.vdct.VisualDCT %*
rem cd /d %OLDDIR%