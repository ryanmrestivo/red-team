@ECHO OFF
SETLOCAL
REM Remember to Run As Administrator otherwise script will silently fail!
REM Get Admin rights.
REM Step 1: Get UAC Admin Rights
:: ------- Start Script ------- 
REM Note, this will not work if run from a network share.

REM From: https://sites.google.com/site/eneerge/home/BatchGotAdmin
:: BatchGotAdmin
:-------------------------------------------------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
	REM NOTIFY user:
	REM wait 2 seconds, in case this user is not in Administrators group. (To prevent a loop of UAC admin requests on a restricted user account.)
	REM wait 2 seconds, in case this user is not in Administrators group. (To prevent an infinite loop of cmd.exe admin requests on a restricted user account.)
	ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
	PING -n 3 127.0.0.1 > nul
    goto UACPrompt
) else ( goto gotAdmin )
:: Debugging: cannot use :: for comments within IF statement, instead use REM

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"	
:-------------------------------------------------------------------------------

SET "_SOURCE=D:\MediaShare"

SET "_DEST=F:\GammaFox Laptop\D-DATA\MediaShare"

SET "_WHAT=/E /XX /XJ"
:: /S - copies Subdirectories, excluding any empty subdirectories.
:: /E - copies subdirectories including Empty ones. For additional information, see Remarks.
:: /COPYALL - COPY ALL file info
:: /B - copy files in Backup mode.
:: /Z - ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting. (Restart Mode)(survive network glitch).(maybe for Network Copys)
:: /SEC - copy files with SECurity
:: /MIR - MIRror a directory tree  (delete any Extra files at the Destination which are not in the Source)
:: /XX - eXclude "eXtra" files and dirs (present in destination but not source)
::       This will prevent any deletions from the destination. (this is the default) (http://ss64.com/nt/robocopy.html)
:: /XJ - eXclude Junction points. (normally included by default). In Windows 7 Junction Points were introduced which adds symbolic-like-links for "Documents and Settings" which redirect to "C:\User\Documents" for old program compatibility. Sometimes they can throw ROBOCOPY into a loop and it will copy the same files more than once.

SET "_OPTIONS=/Z /TEE /R:4 /W:2"
:: /B - copy files in Backup mode.
:: /Z - ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting. (Restart Mode)(survive network glitch).(maybe for Network Copys)
:: /TEE - Output to console window, as well as the log file.
:: /R:n - number of Retries - default is 1 million.
:: /W:n - Wait time between retries - default is 30 seconds.
ECHO Options = %_OPTIONS%
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
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% %~f0"
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Pink Floyd - Interstellar Overdrive.mp3^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Pink Floyd - Matilda Mother.mp3^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Pink Floyd - Astronomy Dominé.mp3^""
::SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Pink Floyd - Astronomy Domin*.mp3^""
SET "_FILE_EXCLUSIONS=%_FILE_EXCLUSIONS% "%_SOURCE%\Billy Joel\01 You May Be Right_mp3.mp3^""
ECHO File exclusions = %_FILE_EXCLUSIONS%
ECHO.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_DIR_EXCLUSIONS=/XD"
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
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\+Downloads^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\+Playlists\Music Video Playlists^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\+MediaMonkey^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Led Zeppelin\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Extra^""
::SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Box Sets^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Pink Floyd\Discography^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\The Beatles\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Optimus Rhyme\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\The Black Keys\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\FIDLAR\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\The Heavy\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\Cage The Elephant\Extra^""
SET "_DIR_EXCLUSIONS=%_DIR_EXCLUSIONS% "%_SOURCE%\MC Frontalot\Extra^""
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
CALL :GetDate
ECHO Sortable date = %_SORTABLE_DATE%
SET "_LOG_FILE=%_LOG_FILE%"%_SORTABLE_DATE_PATH%^""
ECHO Log file = %_LOG_FILE%
ECHO.
PAUSE
ECHO.

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: ROBOCOPY Options/Switches Descriptions: (NOTE THIS LIST IS NOT COMPLETE)
:: robocopy "<source>" "<destination>"
:: Network locations cannot be referred to by a mapped drive letter, and must be "\\computername\sharedfolder\..."
:: e.g. ROBOCOPY C:\source D:\dest *.* /XD "C:\System Volume Information" "C:\$Recycle.Bin" "C:\tmp" /XF pagefile.sys hiberfil.sys

:: /S - copies Subdirectories, excluding any empty subdirectories.
:: /E - copies subdirectories including Empty ones. For additional information, see Remarks.
:: /COPY:<CopyFlags>
:: Specifies the file properties to be copied. The following are the valid values for this option:
::  	D - Data
::  	A - Attributes
::  	T - Time stamps
::	 	S - NTFS access control list (ACL)
::	 	O - Owner information
::	 	U - Auditing information
:: The default value for CopyFlags is DAT (data, attributes, and time stamps).
:: /COPYALL - Copies all file information (equivalent to /copy:DATSOU).
:: /DCOPY:T - COPY Directory Timestamps.
:: /SECFIX - FIX file SECurity on all files, even skipped files.
:: /TIMFIX - FIX file TIMes on all files, even skipped files.
:: /MIR - Mirrors a directory tree (equivalent to /e plus /purge), deletes any destination files. Note that when used with /Z (or MAYBE even /XO) it does not delete already copied files at the destination (useful for resuming a copy)
:: /PURGE - delete dest files/dirs that no longer exist in source.

:: /MOV : MOVe files (delete from source after copying).
:: /MOVE : Move files and dirs (delete from source after copying).

:: /L - Specifies that files are to be listed only (and not copied, deleted, or time stamped).
:: /NP - No Progress – don’t display % copied.
:: /NFL - No file logging
:: /NDL - No dir logging
:: /ETA - Shows the estimated time of arrival (ETA) of the copied files.
:: /BYTES - Print sizes as bytes.
:: /LOG:<LogFile> - Writes the status output to the log file. (overwrites the existing log file)
:: /LOG+:<LogFile> - Appends output to the log file.
:: /TEE - Output to console window, as well as the log file.

:: /IS - Include Same, overwrite files even if they are already the same.
:: /IT - Include Tweaked files.
:: /X - Report all eXtra files, not just those selected & copied.
:: /FFT - uses fat file timing instead of NTFS. This means the granularity is a bit less precise. For across-network share operations this seems to be much more reliable - just don't rely on the file timings to be completely precise to the second.

:: /Z - ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting. (Restart Mode)(survive network glitch).(maybe for Network Copys)
:: /B - copies in Backup Modes (overrides ACLs for files it doesn't have access to so it can copy them. Requires User-Level or Admin permissions)
:: /ZB : Use restartable mode; if access denied use Backup mode.
:: /R:n - Number of Retries on failed copies - default is 1 million.
:: /W:n - Wait time between retries - default is 30 seconds.
:: /REG - Save /R:n and /W:n in the Registry as default settings.

:: /XO - Excludes older files. (Only copies newer and changed files)
:: /XX : eXclude "eXtra" files and dirs (present in destination but not source)
::       This will prevent any deletions from the destination. (this is the default) (http://ss64.com/nt/robocopy.html)
:: /XJ - eXclude Junction points. (normally included by default). In Windows 7 Junction Points were introduced which adds symbolic-like-links for "Documents and Settings" which redirect to "C:\User\Documents" for old program compatibility. Sometimes they can throw ROBOCOPY into a loop and it will copy the same files more than once.
:: /XF <FileName>[ ...] Excludes files that match the specified names or paths. Note that FileName can include wildcard characters (* and ?).
:: /XD <Directory>[ ...] Excludes directories that match the specified names and paths.
:: XF and XD can be used in combination  e.g. ROBOCOPY c:\source d:\dest /XF *.doc *.xls /XD c:\unwanted /S
:: e.g. ROBOCOPY C:\source D:\dest *.* /XD "C:\System Volume Information" "C:\$Recycle.Bin" "C:\tmp" /XF pagefile.sys hiberfil.sys

:: Job Options
::      /JOB:jobname : Take parameters from the named JOB file.
::     /SAVE:jobname : SAVE parameters to the named job file
::             /QUIT : QUIT after processing command line (to view parameters). 

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO.
ECHO Test copy using /L switch . . .
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO.
PAUSE
ECHO.
@ECHO ON

:: Start list operation.
:: ROBOCOPY "%_SOURCE%" "%_DEST%" *.* %_WHAT% /L %_OPTIONS% /XF pagefile.sys hiberfil.sys /XD "%_SOURCE_LETT%\System Volume Information" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp /LOG+:"%USERPROFILE%\Documents\SpiderOak Hive\Programming\Robocopy\BackupD2.log"
ROBOCOPY "%_SOURCE%" "%_DEST%" *.* %_WHAT% /L %_OPTIONS% %_FILE_EXCLUSIONS% %_DIR_EXCLUSIONS% %_LOG_FILE%

@ECHO OFF
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO -------------------------------------------------------------------------------
ECHO.
ECHO Test complete.
ECHO.
PAUSE
ECHO.

ECHO ===============================================================================
ECHO -------------------------------------------------------------------------------
ECHO.
ECHO Copy operation starting . . .
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO.
PAUSE
ECHO.
@ECHO ON

:: Start copy operation.
:: ROBOCOPY "%_SOURCE%" "%_DEST%" *.* %_WHAT% %_OPTIONS% /XF pagefile.sys hiberfil.sys /XD "%_SOURCE_LETT%\System Volume Information" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp /LOG+:"%USERPROFILE%\Documents\SpiderOak Hive\Programming\Robocopy\BackupD2.log"
ROBOCOPY "%_SOURCE%" "%_DEST%" *.* %_WHAT% %_OPTIONS% %_FILE_EXCLUSIONS% %_DIR_EXCLUSIONS% %_LOG_FILE%

@ECHO OFF

ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO -------------------------------------------------------------------------------
ECHO.
ECHO Copy operation complete.
ECHO.
PAUSE

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GOTO SkipFunctions
:: Declare Functions
:-------------------------------------------------------------------------------
:GetDate
:: Get an alphabetically sortable date, returned in a var, in yyyy-mm-dd format.
:: For convienence also get a path returned of "C:\Home Path\this script_yyyy-mm-dd.log" in a var
:: Outputs:
:: "%_SORTABLE_DATE%" (will always be exactly 10 characters long) e.g. 2018-01-28
:: "%_SORTABLE_TIME%" (will always be exactly 8 characters long) e.g. 21-31-39 or 01-57-25
:: "%_FORMATTED_TIME%" (will always be exactly 11 characters long) e.g. " 9:31:39 PM"
:: "%_SORTABLE_DATE_PATH%"
:: "%_SORTABLE_DATETIME_PATH%"
@ECHO OFF
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Get date in format: Dow mm/dd/yyyy (Day-of-week, month/day/year) e.g. Sun 01/28/2018
SET "_DATE=%DATE%"
::ECHO "%_DATE%"
:: Get time in format: hh:mm:ss.ms (24hour:minutes:seconds.miliseconds) e.g. " 1:57:25.57" or "21:31:39.11"
SET "_TIME=%TIME%"
::ECHO "%_TIME%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: https://ss64.com/nt/syntax-substring.html
:: Skip 4 characters and then extract everything else
SET "_DATE_SML=%_DATE:~4%"
:: https://ss64.com/nt/syntax-replace.html
:: Replace the character string '/' with '-'
SET "_DATE_STR=%_DATE_SML:/=-%"
:: We now have the date in mm-dd-yyyy format e.g. 01-28-2018
:: Extract year
SET "_DATE_YEAR=%_DATE_STR:~6,4%"
:: Extract month
SET "_DATE_MONTH=%_DATE_STR:~0,2%"
:: Extract day
SET "_DATE_DAY=%_DATE_STR:~3,2%"
:: Construct an alphabetically sortable date
SET "_DATE_SORT=%_DATE_YEAR%-%_DATE_MONTH%-%_DATE_DAY%"
::ECHO Sortable date = %_DATE_SORT%
:: We now have the date in yyyy-mm-dd format e.g. 2018-01-28
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Extract only the first 8 character
SET "_TIME_SML=%_TIME:~0,8%"
:: Replace the character string ' ' with '0'
SET "_TIME_STR=%_TIME_SML: =0%"
:: Replace the character string ':' with '-'
SET "_TIME_SORT=%_TIME_STR::=-%"
:: We now have the time in 24-hour hh-mm-ss format e.g. 21-31-39 or 01-57-25
::ECHO Sortable time = "%_TIME_SORT%"
SET "_TIME_ANTE_POST=AM"
:: Extract hours
SET "_TIME_24HOUR=%_TIME_SORT:~0,2%"
IF %_TIME_24HOUR% LSS 10 SET "_TIME_24HOUR=%_TIME_24HOUR:~1%"
:: https://ss64.com/nt/if.html
IF %_TIME_24HOUR% GEQ 12 (
	SET "_TIME_ANTE_POST=PM"
	REM https://ss64.com/nt/set.html
	IF %_TIME_24HOUR% GTR 12 (
		SET /A "_TIME_12HOUR=_TIME_24HOUR-12"
	) ELSE (
		SET "_TIME_12HOUR=%_TIME_24HOUR%"
	)
) ELSE (
	SET "_TIME_12HOUR=%_TIME_24HOUR%"
)
:: If 24hr time 'hours' is 00, change to 12 (for 12:00 AM)
IF %_TIME_24HOUR% EQU 0 SET "_TIME_12HOUR=12"
:: Add spaces
IF %_TIME_12HOUR% LSS 10 SET "_TIME_12HOUR= %_TIME_12HOUR%"
:: Skip the hours and extract the rest of :mm:ss from hh:mm:ss e.g. :31:39
SET "_TIME_COLONS=%_TIME_SML:~2%"
SET "_TIME_AMPM=%_TIME_12HOUR%%_TIME_COLONS% %_TIME_ANTE_POST%"
::ECHO 12-hour time with spaces = "%_TIME_AMPM%"
:: We now have the time in 12-hour hh:mm:ss AM/PM format e.g. " 9:31:39 PM"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: https://ss64.com/nt/syntax-args.html
:: %~f1 Expand %1 to a Fully qualified path name - C:\utils\MyFile.txt
SET "_HOME_PATH=%~dpn0"
::ECHO Current path = %_HOME_PATH%
SET "_LOG_PATH=%_HOME_PATH%_%_DATE_SORT%.log"
::ECHO Sortable log path with date = %_LOG_PATH%
:: We now have this script's path & name with _yyyy-mm-dd.log attached e.g. "C:\Home Path\this script_2018-03-07.log"
SET "_LOG_PATH_TIME=%_HOME_PATH%_%_DATE_SORT%_%_TIME_SORT%.log"
::ECHO Sortable log path with date ^& time = %_LOG_PATH_TIME%
:: We now have this script's path & name with _yyyy-mm-dd_hh-mm-ss.log attached e.g. "C:\Home Path\this script_2018-03-07_21-31-39.log"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_SORTABLE_DATE=%_DATE_SORT%" & SET "_SORTABLE_TIME=%_TIME_SORT%" & SET "_FORMATTED_TIME=%_TIME_AMPM%" & SET "_SORTABLE_DATE_PATH=%_LOG_PATH%" & SET "_SORTABLE_DATETIME_PATH=%_LOG_PATH_TIME%"
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
ENDLOCAL

