
:: get chocolatey

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: update environment vars so we don't have to re-open our shell

CALL refreshenv

:: install: VLC player, RTMPDump, RTMPDumpHelper

choco install vlc -y
choco install rtmpdump -y
choco install rtmpdumphelper -y

:: set paths to RTMPDump, RTMPDumpHelper

@SET RTMPpath=%ChocolateyInstall%\lib\RTMPDump\tools\rtmpdump-2.3
@SET RTMPhelperPath=%ChocolateyInstall%\lib\rtmpdumphelper\tools

:: copy link to RTMPDump into RTMPDumpHelper directory

MKLINK %RTMPhelperPath%\rtmpsuck.exe %RTMPpath%\rtmpsuck.exe
MKLINK %RTMPhelperPath%\rtmpsrv.exe %RTMPpath%\rtmpsrv.exe

:: run RTMPDumpHelper

explorer.exe %RTMPhelperPath%
%RTMPhelperPath%\RTMPDumpHelper.exe

@ECHO:
@ECHO All done!
@ECHO:

@PAUSE
