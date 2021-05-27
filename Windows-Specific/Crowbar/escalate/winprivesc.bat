@echo off
title Windows Enumeration and Privilege Escalation Script
echo.
echo Loading System Information, wait a few seconds...
systeminfo > systeminfo.txt 2> nul
find "KB" systeminfo.txt > hotfix.txt 2> nul
cls
:MENU
echo " _       ___       ____       _       ______
echo "| |     / (_)___  / __ \_____(_)   __/ ____/_________
echo "| | /| / / / __ \/ /_/ / ___/ / | / / __/ / ___/ ___/
echo "| |/ |/ / / / / / ____/ /  / /| |/ / /___(__  ) /__
echo "|__/|__/_/_/ /_/_/   /_/  /_/ |___/_____/____/\___/
echo.
echo Windows Enumeration and Privilege Escalation Script
echo www.joshruppe.com ^| Twitter: @josh_ruppe
echo.

echo 1 - All to Report
echo 2 - Operating System
echo 3 - Storage
echo 4 - Networking
echo 5 - Processes
echo 6 - User Info
echo 7 - Return to the Crowbar Framework
echo.
SET /P C=Select^>
echo.
IF %C%==1 GOTO ALL
IF %C%==2 GOTO OS
IF %C%==3 GOTO STORAGE
IF %C%==4 GOTO NETWORK
IF %C%==5 GOTO PROCESSES
IF %C%==6 GOTO USERS
IF %C%==7 GOTO EXIT

:ALL
echo WinPrivEsc >> report.txt
echo Windows Enumeration and Privilege Escalation Script>> report.txt
echo www.joshruppe.com ^| Twitter: @josh_ruppe>> report.txt
echo.>> report.txt
echo Report generated: >> report.txt
echo. >> report.txt
for /F "tokens=* USEBACKQ" %%F IN ('Date') do (
set Date=%%F
echo %Date% >> report.txt
)
echo __________________________ >> report.txt
echo. >> report.txt
echo      OPERATING SYSTEM >> report.txt
echo __________________________>> report.txt
echo.>> report.txt
echo [++OS Name]>> report.txt
echo.>> report.txt
for /F "tokens=3-7" %%a IN ('find /i "OS Name:" systeminfo.txt') do set Name=%%a %%b %%c %%d %%e>> report.txt
echo %Name%>> report.txt
echo.>> report.txt
echo [++OS Version]>> report.txt
echo.>> report.txt
for /F "tokens=3-6" %%a IN ('findstr /B /C:"OS Version:" systeminfo.txt') do set Version=%%a %%b %%c %%d>> report.txt
echo %Version%>> report.txt
echo.>> report.txt
echo.>> report.txt
echo [++System Architecture]>> report.txt
echo.>> report.txt
for /F "tokens=3-4"  %%a IN ('findstr /B /C:"System Type:" systeminfo.txt') do set Type=%%a %%b>> report.txt
echo %Type%>> report.txt
echo.>> report.txt
echo [++System Boot Time]>> report.txt
echo.>> report.txt
for /F "tokens=4-6" %%a IN ('findstr /B /C:"System Boot Time:" systeminfo.txt') do set UpTime=%%a %%b %%c>> report.txt
echo %UpTime%>> report.txt
echo.>> report.txt
echo [++Page File Location(s)]>> report.txt
echo.>> report.txt
for /F "tokens=4" %%a IN ('findstr /B /C:"Page File Location(s):" systeminfo.txt') do set Page=%%a>> report.txt
echo %Page%>> report.txt
echo.>> report.txt
echo [++Hotfix(s) Installed]>> report.txt
echo.>> report.txt
setlocal enabledelayedexpansion
for /F "tokens=2" %%a IN ('findstr /v ".TXT" hotfix.txt') do (
  set Hot=%%~a
  echo !Hot!>> report.txt
)
echo.>> report.txt
echo [++Hosts File]>> report.txt
echo.>> report.txt
more c:\WINDOWS\System32\drivers\etc\hosts>> report.txt
echo.>> report.txt
echo [++Networks File]>> report.txt
echo.>> report.txt
more c:\WINDOWS\System32\drivers\etc\networks>> report.txt
echo.>> report.txt
echo [++Running Services]>> report.txt
echo.>> report.txt
net start>> report.txt
echo.>> report.txt
echo.>> report.txt
echo _________________>> report.txt
echo.>> report.txt
echo      STORAGE >> report.txt
echo _________________>> report.txt
echo.>> report.txt
echo [++Physical Drives]>> report.txt
net share>> report.txt
echo.>> report.txt
echo [++Network Drives]>> report.txt
echo.>> report.txt
net use>> report.txt
echo.>> report.txt
echo.>> report.txt
echo ____________________>> report.txt
echo.>> report.txt
echo      NETWORKING >> report.txt
echo ____________________>> report.txt
echo.>> report.txt
echo [++ICONFIG]>> report.txt
ipconfig /allcompartments /all>> report.txt
echo.>> report.txt
echo [++MAC Addresses]>> report.txt
getmac>> report.txt
echo.>> report.txt
echo [++Route]>> report.txt
echo.>> report.txt
route PRINT>> report.txt
echo.>> report.txt
echo [++Netstat]>> report.txt
netstat -ano>> report.txt
echo.>> report.txt
echo [++ARP]>> report.txt
arp -a>> report.txt
echo.>> report.txt
echo [++Firewall Configuration]>> report.txt
netsh firewall show config>> report.txt
echo [++Domain]>> report.txt
echo.>> report.txt
set userdomain>> report.txt
echo.>> report.txt
echo.>> report.txt
echo ___________________>> report.txt
echo.>> report.txt
echo      PROCESSES >> report.txt
echo ___________________>> report.txt
echo.>> report.txt
echo [++Tasklist]>> report.txt
tasklist /v>> report.txt
echo.>> report.txt
echo [++Drivers Installed]>> report.txt
driverquery /v>> report.txt
echo.>> report.txt
echo.>> report.txt
echo ___________________>> report.txt
echo.>> report.txt
echo      USER INFO >> report.txt
echo ___________________>> report.txt
echo.>> report.txt
echo [++Current User]>> report.txt
echo.>> report.txt
whoami>> report.txt
echo.>> report.txt
echo [++All Users]>> report.txt
net users>> report.txt
echo.>> report.txt
echo [++User Groups]>> report.txt
net localgroup>> report.txt
echo.>> report.txt
echo Done, check report.txt
echo.
del systeminfo.txt
del hotfix.txt
EXIT /B

:OS
echo __________________________
echo.
echo      OPERATING SYSTEM
echo __________________________
echo.
echo [++OS Name]
echo.
for /F "tokens=3-7" %%a IN ('find /i "OS Name:" systeminfo.txt') do set Name=%%a %%b %%c %%d %%e
echo %Name%
echo.
echo [++OS Version]
echo.
for /F "tokens=3-6" %%a IN ('findstr /B /C:"OS Version:" systeminfo.txt') do set Version=%%a %%b %%c %%d
echo %Version%
echo.
echo [++System Architecture]
echo.
for /F "tokens=3-4"  %%a IN ('findstr /B /C:"System Type:" systeminfo.txt') do set Type=%%a %%b
echo %Type%
echo.
echo [++System Boot Time]
echo.
for /F "tokens=4-6" %%a IN ('findstr /B /C:"System Boot Time:" systeminfo.txt') do set UpTime=%%a %%b %%c
echo %UpTime%
echo.
echo [++Page File Location(s)]
echo.
for /F "tokens=4" %%a IN ('findstr /B /C:"Page File Location(s):" systeminfo.txt') do set Page=%%a
echo %Page%
echo.
echo [++Hotfix(s) Installed]
echo.
setlocal enabledelayedexpansion
for /F "tokens=2" %%a IN ('findstr /v ".TXT" hotfix.txt') do (
  set Hot=%%~a
  echo !Hot!
)
echo.
echo [++Hosts File]
echo.
more c:\WINDOWS\System32\drivers\etc\hosts
echo.
echo [++Networks File]
echo.
more c:\WINDOWS\System32\drivers\etc\networks
echo.
echo [++Running Services]
echo.
net start
echo.
del systeminfo.txt
del hotfix.txt
EXIT /B

:STORAGE
echo _________________
echo.
echo      STORAGE
echo _________________
echo.
echo [++Physical Drives]
net share
echo.
echo [++Network Drives]
echo.
net use
del systeminfo.txt
del hotfix.txt
EXIT /B

:NETWORK
echo ____________________
echo.
echo      NETWORKING
echo ____________________
echo.
echo [++ICONFIG]
ipconfig /allcompartments /all
echo.
echo [++MAC Addresses]
getmac
echo.
echo [++Route]
echo.
route PRINT
echo.
echo [++Netstat]
netstat -ano
echo.
echo [++ARP]
arp -a
echo.
echo [++Firewall Configuration]
netsh firewall show config
echo [++Domain]
echo.
set userdomain
echo.
del systeminfo.txt
del hotfix.txt
EXIT /B

:PROCESSES
echo ___________________
echo.
echo      PROCESSES
echo ___________________
echo.
echo [++Tasklist]
tasklist /v
echo.
echo [++Drivers Installed]
driverquery /vw
del systeminfo.txt
del hotfix.txt
EXIT /B

:USERS
echo ___________________
echo.
echo      USER INFO
echo ___________________
echo.
echo [++Current User]
echo.
whoami
echo.
echo [++All Users]
net users
echo.
echo [++User Groups]
net localgroup
echo.
del systeminfo.txt
del hotfix.txt
EXIT /B

:EXIT
del systeminfo.txt
del hotfix.txt
EXIT /B