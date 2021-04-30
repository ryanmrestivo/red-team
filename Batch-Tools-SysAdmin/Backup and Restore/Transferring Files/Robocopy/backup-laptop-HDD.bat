@ECHO OFF
:: Recovery Laptop HDD

REM -------------------------------------------------------------------------------
REM ===============================================================================
:: BatchGotAdmin International-Fix Code
:: Thanks to: https://sites.google.com/site/eneerge/home/BatchGotAdmin
:-------------------------------------------------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
IF '%ERRORLEVEL%' NEQ '0' (
	REM wait 2 seconds, in case this user is not in Administrators group. (To prevent a loop of UAC admin requests on a restricted user account.)
	REM wait 2 seconds, in case this user is not in Administrators group. (To prevent an infinite loop of cmd.exe admin requests on a restricted user account.)
	ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
	PING -n 3 127.0.0.1 > nul
    GOTO UACPrompt
) ELSE ( GOTO gotAdmin )
:: Debugging: cannot use :: for comments within IF statement, instead use REM

:UACPrompt
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%Temp%\getadmin.vbs"
    ECHO UAC.ShellExecute "%~s0", "", "", "RUNAS", 1 >> "%Temp%\getadmin.vbs"

    "%Temp%\getadmin.vbs"
    EXIT /B

:gotAdmin
    IF EXIST "%Temp%\getadmin.vbs" ( DEL "%Temp%\getadmin.vbs" )
    PUSHD "%CD%"
    CD /D "%~dp0"
	ECHO BatchGotAdmin Permissions set.
:-------------------------------------------------------------------------------
ECHO Script name ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.

ECHO:
ECHO -------------------------------------------------------------------------------
:: CLS
SETLOCAL
ECHO.

SET "_SOURCE=F:\"
ECHO Source = %_SOURCE%
ECHO.

:: Set destination to "AAA Music" so it shows up on top in H2 Walker sort
SET "_DEST=D:\"
ECHO Destination = %_DEST%
ECHO.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_FILE_EXCLUSIONS=/XF"
:: /XF <FileName>[ ...] Excludes files that match the specified names or paths. Note that FileName can include wildcard characters (* and ?).
:: XF and XD can be used in combination  e.g. ROBOCOPY c:\source d:\dest /XF *.doc *.xls /XD c:\unwanted /S
:: e.g. ROBOCOPY C:\source D:\dest *.* /XD "C:\System Volume Information" "C:\$Recycle.Bin" "C:\tmp" /XF pagefile.sys hiberfil.sys
:: Common file exclusions:
:: e.g. /XF pagefile.sys hiberfil.sys 
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% pagefile.sys"
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% hiberfil.sys"
:: File exclusions:
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Pink Floyd\*.mp3^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\Docs\+Reference\Software\Adobe\CS5\Adobe CS5.5 Master Collection Content.exe^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\Docs\+Reference\Training\Adobe Software\Dreamweaver\CartoonSmart_Dreamweaver.rar^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\+PlaylistsMedia\Christmas\Mariah Carey-All I Want For Christmas Is You(Sony BMG)(2004)(BPM 75).mp3^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\+PlaylistsMedia\Christmas\Mary Margaret O`Hara-What Are You Doing New Years' Eve(Virgin)(1991)(BPM ).MP3^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\+PlaylistsMedia\Christmas\Matt Monro-From Russia With Love(EMI)(1963).mp3^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\+PlaylistsMedia\Christmas\Matt Monro-Mary's Boy Child(EMI)(1977)(BPM ).MP3^""

::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\Ray Charles\Ray Charles - Complete recordings 1948-1959 - 7CD-BOX 2012\14. Ain't that fine.flac^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Music\Ray Charles\Ray Charles - Complete recordings 1948-1959 - 7CD-BOX 2012\140. Am I blue.flac^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7\Sample Videos\Bondage\Intense Fucking Compilation   Tube Cup.mp4^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7\Sample Videos\Rough\Extreme abuse compilation - TNAFlix Porn Videos.mp4^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Videos\Music Videos\Muse - Psycho Official Lyric Video - YouTube.mp4^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\MediaShare\Videos\TV Shows\Betas\Betas.S01E01.Pilot.720p.WEBRip.AAC2.0.x264-JJ.mkv^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "F:\[Torrent] Completed\Tool - Opiate - Custom Remaster by MC Lurken 24-bit 96kHz flac\06 - Opiate.flac^""

ECHO File exclusions = %_FILE_EXCLUSIONS%
ECHO.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_DIR_EXCLUSIONS=/XD"
:: DO NOT end path with \ or robocopy will not recognize it. 
:: /XD <Directory>[ ...] Excludes directories that match the specified names and paths.
:: XF and XD can be used in combination  e.g. ROBOCOPY c:\source d:\dest /XF *.doc *.xls /XD c:\unwanted /S
:: e.g. ROBOCOPY C:\source D:\dest *.* /XD "C:\System Volume Information" "C:\$Recycle.Bin" "C:\tmp" /XF pagefile.sys hiberfil.sys
:: Common directory exclusions:
:: e.g. /XD "%_SOURCE_LETT%\System Volume Information" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp 
:: Get the _SOURCE drive letter
FOR /F %%G IN ("%_SOURCE%") DO (SET _SOURCE_LETT=%%~dG)
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% ^"%_SOURCE_LETT%\System Volume Information^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% %_SOURCE_LETT%\$Recycle.Bin"
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% %_SOURCE_LETT%\tmp"
:: Directory exclusions:
:: Remove the first carrot before the doublequote, why, Idfk
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Music\+PlaylistsMedia\Sound Tracks^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\Docs\+Reference\Software\Adobe\CS5^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\Docs\+Reference\Training\Adobe Software\Dreamweaver^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\Docs\+Reference\Training\Adobe Software\Dreamweaver^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\Docs\+Reference\Training\PUA^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\Docs\+Reference\Training\PUA^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\Docs\+Reference\Training\PUA\Pandora's Box System^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Docs\+Reference\MarTek Docs^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\MediaShare\Docs\+Reference\MarTek Docs^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\MediaShare\Music\+PlaylistsMedia\Christmas^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\MediaShare\Music\Guardians of the Galaxy Awesome Mix Volume 2^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Videos\Music Videos^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Videos\TV Shows^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\MediaShare\Videos\TV Shows\Betas^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE_LETT%\[Torrent] Completed\Tool - Opiate - Custom Remaster by MC Lurken 24-bit 96kHz flac^""
::F:\[Torrent] Completed\Tool - Opiate - Custom Remaster by MC Lurken 24-bit 96kHz flac\


ECHO Directory exclusions = %_DIR_EXCLUSIONS%
ECHO.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_LOG_FILE=/LOG+:"
:: /LOG:<LogFile> - Writes the status output to the log file. (overwrites the existing log file)
:: /LOG+:<LogFile> - Appends output to the log file.
:: /NFL - No file logging
:: /NDL - No dir logging
:: /NP - No Progress – don’t display % copied.
SET "_DATE=%DATE%"
ECHO Current date = %_DATE%
:: https://ss64.com/nt/syntax-substring.html
:: Skip 4 characters and then extract everything else
SET "_DATE_SML=%_DATE:~4%"
:: https://ss64.com/nt/syntax-replace.html
:: Replace the character string '/' with '-'
SET "_DATE_STR=%_DATE_SML:/=-%"
ECHO Date string = %_DATE_STR%
:: https://ss64.com/nt/syntax-args.html
:: %~f1 Expand %1 to a Fully qualified path name - C:\utils\MyFile.txt
:: SET "_HOME_PATH=%~dpn0"
:: SET "_HOME_PATH=%~dp0Logs\%~n0"
SET "_HOME_PATH=D:\%~n0"
::ECHO Current path = %_HOME_PATH%
SET "_LOG_PATH=%_HOME_PATH%_%_DATE_STR%.log"
::ECHO Log path = %_LOG_PATH%
SET "_LOG_FILE=%_LOG_FILE%"%_LOG_PATH%^""
ECHO Log file = %_LOG_FILE%
ECHO.

REM ===============================================================================
REM -------------------------------------------------------------------------------

PAUSE
ECHO:
ECHO -------------------------------------------------------------------------------
ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO:

:: Copy File structure only first
:: https://social.technet.microsoft.com/Forums/windows/en-US/0b3d3006-0e0f-4c95-9e2f-4c820832ebfa/using-robocopy-to-copy-folder-structure-only?forum=w7itprogeneral

::robocopy F:/ D:/ *.* /e /xf * %_DIR_EXCLUSIONS%

:: DONE!
:: -------------------------------------------------------------------------------
::robocopy %_SOURCE% %_DEST% *.* /e /xf * %_DIR_EXCLUSIONS%

ECHO:
ECHO -------------------------------------------------------------------------------
ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO:
PAUSE



ECHO:
ECHO -------------------------------------------------------------------------------
ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO:

:: Start copying files
::

robocopy %_SOURCE% %_DEST% *.* /E /XJ /XX /Z /TEE /R:2 /W:30  %_FILE_EXCLUSIONS% %_DIR_EXCLUSIONS% %_LOG_FILE%
:: /E - copies subdirectories including Empty ones. For additional information, see Remarks.
:: /XX - eXclude "eXtra" files and dirs (present in destination but not source)
::       This will prevent any deletions from the destination. (this is the default) (http://ss64.com/nt/robocopy.html)
:: /XJ - eXclude Junction points. (normally included by default). In Windows 7 Junction Points were introduced which adds symbolic-like-links for "Documents and Settings" which redirect to "C:\User\Documents" for old program compatibility. Sometimes they can throw ROBOCOPY into a loop and it will copy the same files more than once.


:: /B - copy files in Backup mode. (/B (backup mode) will allow Robocopy to override file and folder permission settings (ACLs). Backup mode requires RC to be run fromaccount with enough privileges to accomplis this trick. Normally RC respects teh ACL restrictions.)
:: /Z - ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting. (Restart Mode)(survive network glitch).(maybe for Network Copys)
:: /TEE - Output to console window, as well as the log file.
:: /R:n - number of Retries - default is 1 million.
:: /W:n - Wait time between retries - default is 30 seconds.

:: Exclusions due to read locks:
::F:\Docs\+Reference\Software\Adobe\CS5\Adobe CS5.5 Master Collection Content.exe
::F:\Docs\+Reference\Training\Adobe Software\Dreamweaver\
::F:\Docs\+Reference\Training\Adobe Software\Dreamweaver\CartoonSmart_Dreamweaver.rar
::F:\Docs\+Reference\Training\PUA\
::F:\Docs\+Reference\Training\PUA\Pandora's Box System\
::F:\MediaShare\Docs\+Reference\MarTek Docs\
::F:\MediaShare\Docs\+Reference\MarTek Docs\AG Disk 1.iso
::F:\MediaShare\Music\+PlaylistsMedia\Christmas\Mariah Carey-All I Want For Christmas Is You(Sony BMG)(2004)(BPM 75).mp3
::F:\MediaShare\Music\Guardians of the Galaxy Awesome Mix Volume 2\
::F:\MediaShare\Music\Ray Charles\Ray Charles - Complete recordings 1948-1959 - 7CD-BOX 2012\14. Ain't that fine.flac
::F:\MediaShare\Music\Ray Charles\Ray Charles - Complete recordings 1948-1959 - 7CD-BOX 2012\140. Am I blue.flac
::F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7\
::F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7\Sample Videos\Bondage\Intense Fucking Compilation   Tube Cup.mp4 # 88.6 mb
::F:\MediaShare\Videos\Music Videos\
::F:\MediaShare\Videos\Music Videos\Muse - Psycho Official Lyric Video - YouTube.mp4 # 93.5 mb
::F:\MediaShare\Videos\TV Shows\
::F:\MediaShare\Videos\TV Shows\Betas\Betas.S01E01.Pilot.720p.WEBRip.AAC2.0.x264-JJ.mkv
::F:\MediaShare\Pictures\+Archive\ZDYBK-J1ANL-JU9VC-IU3U5-W4BW7\Sample Videos\Rough\Extreme abuse compilation - TNAFlix Porn Videos.mp4
::F:\MediaShare\Music\+PlaylistsMedia\Christmas\Mary Margaret O`Hara-What Are You Doing New Years' Eve(Virgin)(1991)(BPM ).MP3
::F:\MediaShare\Music\+PlaylistsMedia\Christmas\Matt Monro-From Russia With Love(EMI)(1963).mp3
::F:\MediaShare\Music\+PlaylistsMedia\Christmas\Matt Monro-Mary's Boy Child(EMI)(1977)(BPM ).MP3









ECHO:
ECHO -------------------------------------------------------------------------------
ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO:
PAUSE

:: Remove saved files from old HDD (to clear up space, making it easier to read old 

:: 46.2 GB
::F:\Docs\+Reference\Software\Microsoft

:: RMDIR F:\Docs\+Reference\Software\Microsoft



ECHO:
ECHO -------------------------------------------------------------------------------
ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO:
PAUSE



ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO -------------------------------------------------------------------------------
ECHO.
ECHO Operation complete.
ECHO.
PAUSE

ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
ENDLOCAL



