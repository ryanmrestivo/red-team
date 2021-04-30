@echo off

:checkPrivileges
NET FILE 1>NUL 2>NUL

if '%errorlevel%' == '0' (
  goto mainScript 
) else (
  goto getPrivileges
)
::-------------------------------------------------------------------------------------------------

:getPrivileges
  if '%1'=='ELEV' (shift & goto mainScript)
  echo.
  echo Selbstausfuehrung mit Administratorrechten...
  setlocal DisableDelayedExpansion
  set "batchPath=%~0"
  setlocal EnableDelayedExpansion
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\runAsAdmin.vbs"
  echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\runAsAdmin.vbs"
  "%temp%\runAsAdmin.vbs"
  exit /B
::-------------------------------------------------------------------------------------------------


:mainScript
REM Here we are doing admin stuff...
  cls
  echo Hallo Welt >C:\test.txt