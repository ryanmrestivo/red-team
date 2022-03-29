:: Script       : windows-enumeration
:: Description  : Local enumeration on windows, output to "output.txt" at the location the batch file is run.
:: Notes        : This is very 'loud' and should only be used for ethical purposes.  Contact me with any questions or if you require assistance.
:: Version      : 1.0

@echo off

echo ... Enumeration started...

echo ##################Hostname > output.txt
hostname >> output.txt
echo. >> output.txt

echo ##################whoami >> output.txt
whoami >> output.txt
echo. >> output.txt

echo ##################echo %%USERNAME%% >> output.txt
echo %USERNAME% >> output.txt
echo. >> output.txt

echo ##################net users >> output.txt
net users >> output.txt
echo. >> output.txt

echo ##################net user %%USERNAME%% >> output.txt
net user %USERNAME% >> output.txt
echo. >> output.txt

echo ################## systeminfo >> output.txt
systeminfo >> output.txt
echo. >> output.txt

echo ################## fsutil fsinfo drives >> output.txt
echo ################## (shows mounted drives) >> output.txt
fsutil fsinfo drives >> output.txt
echo. >> output.txt

echo ################## path >> output.txt
echo %PATH% >> output.txt
echo. >> output.txt

echo ################## tasklist /SVC >> output.txt
tasklist /SVC >> output.txt
echo. >> output.txt

echo ################## Checking if .msi files are always installed with elevated privlidges >> output.txt
echo ################## NOTE: Both values below must be 1 >> output.txt
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated /v AlwaysInstallElevated >> output.txt
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated /v AlwaysInstallElevated >> output.txt
echo. >> output.txt

echo #### Checking for backup SAM files >> output.txt

echo #### dir %SYSTEMROOT%\repair\SAM >> output.txt
dir %%SYSTEMROOT%%\repair\SAM >> output.txt

echo #### dir %SYSTEMROOT%\system32\config\regback\SAM >> output.txt
dir %%SYSTEMROOT%%\system32\config\regback\SAM >> output.txt
echo. >> output.txt

echo #### Checking for vulnerable services that can be modified by unprivlidged users >> output.txt
echo #### USES AccessChk from sysinternals >> output.txt

echo ##################################################### >> output.txt
echo ################## Checking for possible creds >> output.txt
echo ##################################################### >> output.txt

echo ################## type c:\sysprep.inf >> output.txt
type c:\sysprep.inf >> output.txt
echo. >> output.txt

echo ################## type c:\sysprep\sysprep.xml>> output.txt
type c:\sysprep\sysprep.xml >> output.txt
echo. >> output.txt

echo ##################################################### >> output.txt
echo ################## Network Information >> output.txt
echo ##################################################### >> output.txt

echo ################## ipconfig /all >> output.txt
ipconfig /all >> output.txt
echo. >> output.txt

echo ################## net use (view current connetions) >> output.txt
net use >> output.txt
echo. >> output.txt

echo ################## net share (view shares) >> output.txt
net share >> output.txt
echo. >> output.txt

echo ################## arp -a >> output.txt
arp -a >> output.txt
echo. >> output.txt

echo ################## route print>> output.txt
route print >> output.txt
echo. >> output.txt

echo ################## netstat -nao >> output.txt
netstat -nao >> output.txt
echo. >> output.txt

echo ################## FIREWALL INFORMATION >> output.txt
echo ################## netsh firewall show state >> output.txt
netsh firewall show state >> output.txt
echo. >> output.txt

echo ################## netsh firewall show config >> output.txt
netsh firewall show config >> output.txt
echo. >> output.txt

echo ################## netsh wlan export profile key=clear >> output.txt
echo ################## Shows wireless network information>> output.txt
netsh wlan export profile key=clear
type wi-fi*.xml >> output.txt
del wi-fi*.xml
echo. >> output.txt

echo ... The output above reports that .xml files are created.  Once created, the files are exported to the output.txt file and the *.xml file is subsequently deleted.

echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo ... Writing scheduled tasks, network information, drivers, etc. to disk...
echo ... If this task appears 'frozen' don't worry, it takes about 30 seconds.

echo ##################################################### >> output.txt
echo ################## Scheduled tasks >> output.txt
echo ##################################################### >> output.txt

echo ################## schtasks /query /fo LIST /v >> output.txt
schtasks /query /fo LIST /v >> output.txt
echo. >> output.txt

echo ################## Net start >> output.txt
net start >> output.txt
echo. >> output.txt

echo ################## Drivers >> output.txt
DRIVERQUERY >> output.txt
echo. >> output.txt

echo ##################################################### >> output.txt
echo ################## Any mentions of "password" in the registry >> output.txt
echo ##################################################### >> output.txt

reg query HKLM /f password  /t REG_SZ  /s >> output.txt
echo. >> output.txt

echo. >> output.txt

echo ################## Network Services >> output.txt
net config Workstation >> output.txt
echo. >> output.txt

echo ################## Usernames >> output.txt
cd C:\ & findstr /SI /M "username" *.xml *.ini *.txt >> output.txt
echo. >> output.txt
echo ################## Passwords >> output.txt
cd C:\ & findstr /SI /M "password" *.xml *.ini *.txt >> output.txt
echo. >> output.txt

echo ################## Registry credential usernames >> output.txt
echo. >> output.txt

REG QUERY HKLM /F "username" /t REG_SZ /S /K >> output.txt
echo. >> output.txt
REG QUERY HKCU /F "username" /t REG_SZ /S /K >> output.txt
echo. >> output.txt

echo ################## Registry credential passwords >> output.txt
REG QUERY HKLM /F "password" /t REG_SZ /S /K >> output.txt
echo. >> output.txt
REG QUERY HKCU /F "password" /t REG_SZ /S /K >> output.txt
echo. >> output.txt

echo ################## Startup tasks >> output.txt
echo. >> output.txt
wmic startup get caption,command,user >> output.txt
echo. >> output.txt

echo ################## Stored credentials >> output.txt
echo. >> output.txt
cmdkey /list >> output.txt
echo. >> output.txt

echo ... If output above reads "Access is denied." : This is likely a result of system hardening of the registry.  This is good.

echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .
echo  .

echo ... Enumeration complete.  Closing.

::  This command "starts" a new process in this console, then deletes the initial process .bat file.
start /b "" cmd /c del "%~f0"&exit /b

:: This is currently disabled for debugging
:: echo ################## Services which arn't properly quoted >> output.txt
:: wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """

:: This is currently disabled for debugging
:: accesschk.exe -uwcqv "Authenticated Users" * /accepteula >> output.txt
:: accesschk.exe -uwcqv "Users" * /accepteula >> output.txt
:: accesschk.exe -uwcqv "Everyone" * /accepteula >> output.txt

:: Removing the comment on the command below will cause the batch file to remain open at completion.
:: cmd /k
