@echo off

REM PCI_Configs - Checks Windows systems for PCI Compliance
REM Copyright (C) 2014 Joseph Barcia - joseph@barcia.me
REM https://github.com/jbarcia
REM
REM License
REM -------
REM This tool may be used for legal purposes only.  Users take full responsibility
REM for any actions performed using this tool.  The author accepts no liability
REM for damage caused by this tool.  If you do not accept these condition then
REM you are prohibited from using this tool.
REM
REM In all other respects the GPL version 2 applies:
REM
REM This program is free software; you can redistribute it and/or modify
REM it under the terms of the GNU General Public License version 2 as
REM published by the Free Software Foundation.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License along
REM with this program; if not, write to the Free Software Foundation, Inc.,
REM 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
REM
REM You are encouraged to send comments, improvements or suggestions to
REM me at joseph@barcia.me
REM
REM
REM Description
REM -----------
REM Auditing tool to check for PCI Compliance and the specific requirements
REM associated with the corresponding output files.
REM 
REM It is intended to be run by security auditors and pentetration testers 
REM against systems they have been engaged to assess, and also by system 
REM admnisitrators who want to check configuration files for PCI Compliance.
REM
REM Ensure that you have the appropriate legal permission before running it
REM someone else's system.
REM
REM
REM Changelog
REM ---------
REM
REM ------------
set version=2.4
REM ------------
REM Added Active Directory password last changed
REM Added Active Directory password never expires
REM ------------
REM version=2.3
REM ------------
REM Added Active Directory Queries - Active/Inactive/Disabled
REM Added Logging configuration settings
REM ------------
REM version=2.x
REM ------------
REM Added Directory Structure and Requirement Numbers
REM Added tools directory
REM Added Patching Information
REM Added screensaver, audit, rdp sessions


REM sets file location to where the script is run from
set filedir=%~dp0


REM Needed Variables - DO NOT CHANGE
REM ******************************************************************************
REM Sets date
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set weekday=%%a& set month=%%b& set day=%%c& set year=%%d)
for /f "tokens=1-3 delims=: " %%a in ('TIME /t') do (set hour=%%a& set minute=%%b& set second=%%c)
set fdate=%year%%month%%day%-%hour%%minute%
REM echo %fdate%
SETLOCAL EnableDelayedExpansion
REM Sets Hostname
FOR /F "usebackq" %%i IN (`hostname`) DO SET Hostname=%%i

set tempdir=%USERPROFILE%\Desktop\%fdate%-%SiteName%-%Hostname%
REM ******************************************************************************

cls

:Top
echo PCI 2.0 Audit V_%version%
echo:
echo:

if not exist "%filedir%\tools\WinAudit.exe" GOTO MissingFiles
if not exist "%filedir%\tools\7za.exe" GOTO MissingFiles

:Assessment
	echo Enter Site Name
	set /p SiteName= : %=%
	echo:
	set tempdir=%USERPROFILE%\Desktop\%fdate%-%SiteName%-%Hostname%
	if exist "%tempdir%" echo *****WARNING: %tempdir% already exists rename the folder to prevent data loss***** && pause
	if not exist "%tempdir%" mkdir "%tempdir%"
echo:

:Domain
cls
color 0A
echo PCI 2.0 Audit V_%version%
echo:
echo:
echo SITE:  	%SiteName% 
echo:
echo --------------------------------------------------
echo Configuring the Domain Information (ex. domain.com)
echo --------------------------------------------------
echo Enter the Sub Domain without the (.) (left label) (ex. domain)
set /p subdomain= : %=%
echo:
echo:
echo Enter the Top Level Domain without the (.) (right-most label) (ex. com)
set /p top-level-domain= : %=%
echo:
echo:
echo:
echo DOMAIN:	%subdomain%.%top-level-domain%
echo Is the Domain correct? [Y]
set answer=n
set /p answer= : %=%
IF %answer%==n GOTO Domain
IF %answer%==N GOTO Domain
IF %answer%==y GOTO Script
IF %answer%==Y GOTO Script


:Script
REM Lets make some directories...
	mkdir "%tempdir%\ScheduleJobs"
	mkdir "%tempdir%\Req 1"
	mkdir "%tempdir%\Firewall"
	mkdir "%tempdir%\Network"
	mkdir "%tempdir%\Req 2"
	mkdir "%tempdir%\Req 6"
	mkdir "%tempdir%\Req 8"
	mkdir "%tempdir%\Req 10"
	if not exist "%filedir%\Saved" mkdir "%filedir%\Saved"

cls
color 0A
echo PCI 2.0 Audit V_%version%
echo:
echo:
echo SITE:  	%SiteName% 
echo DOMAIN:	%subdomain%.%top-level-domain%
echo:
	echo --------------------------------------------------
	echo  Grabbing Kernel Version
	echo --------------------------------------------------
		ver >> "%tempdir%\Req 6\6.1 %Hostname% Kernel Version.txt"
	echo --------------------------------------------------
	echo  Grabbing System Information
	echo --------------------------------------------------
		systeminfo >> "%tempdir%\%Hostname% System Information.txt"
	echo --------------------------------------------------
	echo  Grabbing GPO Settings
	echo --------------------------------------------------
		gpresult /z >> "%tempdir%\%Hostname% GPO Settings.txt"
	echo --------------------------------------------------
	echo  Grabbing Hosts File
	echo --------------------------------------------------
		type %WINDIR%\System32\drivers\etc\hosts >> "%tempdir%\Network\1.3.7-8 %Hostname% Hosts.txt"
		ipconfig /all >> "%tempdir%\Req 1\1.3.7-8 %Hostname% Network Configuration.txt"
	echo --------------------------------------------------
	echo  Grabbing Running Services
	echo --------------------------------------------------
		sc query >> "%tempdir%\Req 2\2.2.2 %Hostname% Running Services.txt"
		sc queryex >> "%tempdir%\Req 2\2.2.2 %Hostname% Running Services 2.txt"
	echo --------------------------------------------------
	echo  Grabbing Listening Services
	echo --------------------------------------------------
		netstat -nao | findstr LISTENING >> "%tempdir%\Req 2\2.2.2 %Hostname% Listening Services.txt"
		netstat –r >> "%tempdir%\Req 2\2.2.2 %Hostname% Listening Services 2.txt"
		netstat –nabo >> "%tempdir%\Req 2\2.2.2 %Hostname% Listening Services 3.txt"
		netstat -na | findstr :21 >> "%tempdir%\Req 2\2.2.2 %Hostname% Listening Services FTP.txt" 
		netstat -na | findstr :23 >> "%tempdir%\Req 2\2.2.2 %Hostname% Listening Services Telnet.txt" 
	echo --------------------------------------------------
	echo  Grabbing Domain Password Policy Settings
	echo --------------------------------------------------
		net accounts /domain >> "%tempdir%\Req 8\8.5 %Hostname% Domain Password Policies.txt" 
	echo --------------------------------------------------
	echo  Grabbing Local Password Policy Settings
	echo --------------------------------------------------
		net accounts >> "%tempdir%\Req 8\8.5 %Hostname% Local Password Policies.txt" 
	echo --------------------------------------------------
	echo  Grabbing Current User
	echo --------------------------------------------------
		whoami >> "%tempdir%\Req 8\8.1 %Hostname% Current User.txt"
	echo --------------------------------------------------
	echo  Grabbing Local Administrator Accounts
	echo --------------------------------------------------
		net localgroup administrators >> "%tempdir%\Req 8\8.1 %Hostname% Local Administrators.txt" 
	echo --------------------------------------------------
	echo  Grabbing Domain Administrator Accounts
	echo --------------------------------------------------
		net localgroup administrators /domain >> "%tempdir%\Req 8\8.1 %Hostname% Domain Administrators.txt"  
		net group "Domain Admins" /domain >> "%tempdir%\Req 8\8.1 %Hostname% Domain Administrators 2.txt"  
		net group “Enterprise Admins” /domain >> "%tempdir%\Req 8\8.1 %Hostname% Enterprise Administrators.txt" 
		net group “Domain Controllers” /domain >> "%tempdir%\Req 8\8.1 %Hostname% Domain Controllers.txt"  
	echo --------------------------------------------------
	echo  Grabbing Local Firewall Settings
	echo --------------------------------------------------
		netsh advfirewall firewall show rule name=all >> "%tempdir%\Req 1\1.4 %Hostname% Local Firewall Settings.txt"
	echo --------------------------------------------------
	echo  Grabbing Patch Information
	echo --------------------------------------------------
		wmic qfe list full /format:htable >> "%tempdir%\Req 6\6.1 %Hostname% Patch Information.html"
	echo --------------------------------------------------
	echo  Grabbing NTP Settings
	echo --------------------------------------------------
		reg query HKLM\SYSTEM\CurrentControlSet\services\W32Time\Parameters\ /v NtpServer >> "%tempdir%\Req 10\10.4 %Hostname% NTP Configurations.txt"  
	echo --------------------------------------------------
	echo Dump of Audit Category Settings
	echo --------------------------------------------------
		Auditpol /get /category:* >> "%tempdir%\Req 10\10.2 %Hostname% Local Audit Settings.txt"
	echo --------------------------------------------------
	echo Grabbing the Screensaver Settings
	echo --------------------------------------------------
		reg query "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive >> "%tempdir%\Req 8\8.5.15 %Hostname% Screensaver Settings.txt"
		reg query "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaverIsSecure >> "%tempdir%\Req 8\8.5.15 %Hostname% Screensaver Settings.txt"
		reg query "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut >> "%tempdir%\Req 8\8.5.15 %Hostname% Screensaver Settings.txt" 
	echo --------------------------------------------------
	echo Grabbing RDP Encryption and Idle Settings
	echo --------------------------------------------------
		reg query "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		echo: >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		echo 1 = low >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		echo 2 = client compatible >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		echo 3 = high >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		echo 4 = fips >> "%tempdir%\Req 8\8.4 %Hostname% RDP Encryption Setting.txt"
		reg query "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxIdleTime >> "%tempdir%\Req 8\8.5.15 %Hostname% RDP Timeout Setting.txt"
	echo --------------------------------------------------
	echo  Grabbing Scheduled Jobs
	echo --------------------------------------------------
		schtasks /query /fo CSV /v >> "%tempdir%\ScheduleJobs\%Hostname% Scheduled Tasks.csv"
REM	echo --------------------------------------------------
REM	echo  Executing WinAudit
REM	echo --------------------------------------------------
REM		cd %filedir%\tools\
REM		WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArCHGBLJF /o=XML /f="%tempdir%\%Hostname% WinAudit.xml" /m="Coalfire PCI WinAudit"

cd %filedir%\tools\
	echo --------------------------------------------------
	echo Dump of active Active Directory users
	echo --------------------------------------------------
REM		dsquery.exe * -limit 0 -filter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2))" >"%tempdir%\Req 8\8.5.4_6 %Hostname% Domain Active Users.txt"
		dsquery.exe * -filter (msRTCSIP-UserEnabled=TRUE) -limit 0 -attr name samaccountname >>"%tempdir%\Req 8\8.5.4_6 %Hostname% Domain Active Users.txt"
echo:
echo:
	echo --------------------------------------------------
	echo Dump of Disabled Active Directory users
	echo --------------------------------------------------
		dsquery.exe user "dc=%subdomain%,dc=%top-level-domain%" -disabled -limit 0 >"%tempdir%\Req 8\8.5.4_6 %Hostname% Domain Disabled Users.txt"
echo:
echo:
	echo --------------------------------------------------
	echo Dump of inactive Active Directory users
	echo --------------------------------------------------
		dsquery.exe user "dc=%subdomain%,dc=%top-level-domain%" -inactive 13 -limit 0 >"%tempdir%\Req 8\8.5.5 %Hostname% Inactive Users.txt"
echo:
echo:
	echo --------------------------------------------------
	echo Dump of users whose Password Never Expire
	echo --------------------------------------------------
		dsquery.exe * -limit 0 -filter "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))" -attr samaccountname name >"%tempdir%\Req 8\8.5 %Hostname% Users Password Don't Expire.txt"
echo:
echo:
	echo --------------------------------------------------
	echo Dump of users and Their Last Password Change
	echo --------------------------------------------------	 
		FOR /F "skip=1 tokens=1-4 delims= " %%a IN ('Dsquery * -filter "&(objectClass=User)(objectCategory=Person)" -limit 0 -attr name pwdlastset ') DO (
			FOR /F "tokens=3-4 delims=-( " %%w IN ('%systemroot%\system32\w32tm /ntte %%b') DO SET tmpLLTS=%%w 
			FOR /F "tokens=3-4 delims=-( " %%x IN ('%systemroot%\system32\w32tm /ntte %%c') DO SET tmpPLT=%%x 
			FOR /F "tokens=4-4 delims=-( " %%y IN ('%systemroot%\system32\w32tm /ntte %%b') DO SET tmpLLLTS=%%y
			FOR /F "tokens=4-4 delims=-( " %%z IN ('%systemroot%\system32\w32tm /ntte %%c') DO SET tmpPLLT=%%z 
			FOR /F "tokens=5-5 delims=-( " %%t IN ('%systemroot%\system32\w32tm /ntte %%b') DO SET tmpPLLLT=%%t
		REM	echo %%a	!tmpLLTS!	!tmpPLT!	!tmpLLLTS!	!tmpPLLT!	!tmpPLLLT! >> "%tempdir%\Req 8\8.5 %Hostname% Users Last Password Changed.txt")
		echo %%a	!tmpLLLTS! ----- !tmpPLT!	!tmpPLLT!	!tmpPLLLT! >> "%tempdir%\Req 8\8.5 %Hostname% Users Last Password Changed.txt")
echo:
echo:
pause
	echo --------------------------------------------------
	echo  Packaging up the Files
	echo --------------------------------------------------
		cd %filedir%\tools\
		7za.exe a -t7z "%USERPROFILE%\Desktop\%fdate%-%SiteName%-%Hostname%.7z" "%tempdir%\*.*" -r
		rmdir "%tempdir%" /s /q
	echo .
	echo ..
	echo ...
	echo ....
	echo Your files are located here: 
	echo %USERPROFILE%\Desktop\%fdate%-%SiteName%-%Hostname%.7z
	pause
	GOTO END
	
:MissingFiles
	echo Files missing...Please extract all of the files including the tools.
	pause

:END
