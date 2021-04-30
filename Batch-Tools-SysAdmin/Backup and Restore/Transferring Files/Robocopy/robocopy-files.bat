@echo off
SETLOCAL
@echo off
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
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

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
REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Set vars
set "_SOURCE_LOC=D:\Docs\+VideoProjects"
::
set "_DEST_LOC=%USERPROFILE%\Documents\+VideoProjects"
:: To save logs in same directory as this script, set "_LOG_PATH=%~dp0"
set "_LOG_PATH=%~dp0"
::

REM Abstract other VARS from source
REM --get drive letter of source
FOR /F %%G IN ("%_SOURCE_LOC%") DO (SET _SOURCE_LETT=%%~dG)
:: Set RoboCopy switches
::
::
:: Define the options/switches you want here (will apply to real copy as well):
set "ROBOSWITCHES=/E /XF pagefile.sys hiberfil.sys Backup-PC-HomeComp3-18-11.TBI /XD "%_SOURCE_LETT%\System Volume Information^" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp ^/XJ ^/TEE"
::
::
::
REM Abstract other VARS from source
REM --Escape ampersands
set _SOURCE_LOC_FORM=%_SOURCE_LOC:&=^^^&%
set _DEST_LOC_FORM=%_DEST_LOC:&=^^^&%

echo(

REM --escape double quotes
set _ROBOSWITCH_MAD=%ROBOSWITCHES:"=^^^"%

echo(


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
REM CLS
echo(
echo -------------------------------------------------------------------------------
echo(
echo ROBOCOPY for large file transfers!
echo(
echo  T - for Test copy (log only)
echo  Y - Yes, perform full copy
echo  N - No/Abort
echo(
CHOICE /C TYN /M "Are you ready?"
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO COPY
IF ERRORLEVEL 1 GOTO TEST
GOTO END

:COPY
set "SHHHHTESTING=/l "
set "SHHHHTESTING="
set "PRINTTOSCREEN=/eta "
set "NOPROGRESS=/NP "
set "NOPROGRESS="
set "RETRYSETTINS=/r:1 /w:1 "
REM NOTIFY user:
echo(
REM echo ROBOCOPY %_SOURCE_LOC%\ %_DEST_LOC_FORM%\ *.* /S /XF pagefile.sys hiberfil.sys Backup-PC-HomeComp3-18-11.TBI /XD "%_SOURCE_LETT%\System Volume Informatio^" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp /XJ /TEE %NOPROGRESS%%RETRYSETTINS%%PRINTTOSCREEN%%SHHHHTESTING%/log+:"%_LOG_PATH%ROBOCOPY.log"
echo(
echo This one's the real deal! You sure?
echo(
pause
echo(
echo Performing copy...
echo(

ROBOCOPY %_SOURCE_LOC%\ %_DEST_LOC%\ *.* /E /XF pagefile.sys hiberfil.sys Backup-PC-HomeComp3-18-11.TBI /XD "%_SOURCE_LETT%\System Volume Information" %_SOURCE_LETT%\$Recycle.Bin %_SOURCE_LETT%\tmp /XJ /TEE %NOPROGRESS%%RETRYSETTINS%%PRINTTOSCREEN%%SHHHHTESTING%/log+:"%_LOG_PATH%ROBOCOPY.log"
REM To interrupt a in-progress copy use Ctrl+C, and /XO & /Z switches to resume from last left off.
::
::
::
REM START "Performing ROBOCOPY..." /W "robocopy" %_SOURCE_LOC%\ %_DEST_LOC%\ *.* %ROBOSWITCHES% %NOPROGRESS%%RETRYSETTINS%%PRINTTOSCREEN%%SHHHHTESTING%/log+:"%_LOG_PATH%ROBOCOPY.log"
::
::
::
echo ===============================================================================
echo RoboCopy script Complete!
echo(
pause
GOTO END

:TEST
set "SHHHHTESTING="
set "SHHHHTESTING=/L "
set "PRINTTOSCREEN=/eta "
set "PRINTTOSCREEN="
set "NOPROGRESS="
set "NOPROGRESS=/NP "
set "RETRYSETTINS=/r:0 /w:0 "
echo(
echo TESTING TESTING TESTING ...
echo(
:: Works better in PowerShell
@ECHO ON
powershell ROBOCOPY C:\Users\G\Documents\Bandicam D:\Docs\Bandicam *.* /E /XJ /XO /XX /tee /r:0 /w:0 /ETA /log:C:\bandicam.log
@echo off
echo(
echo ===============================================================================
echo Test Complete!
echo(
pause
GOTO END

:END
ENDLOCAL
exit
