@ECHO OFF
SETLOCAL
:: CMD /K Debug-TroubleshootBatchFile.bat
:: CMD /K Debug-TroubleshootBatchFile.bat "%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Functions list\functions-template.bat"
:: CMD /K Debug-TroubleshootBatchFile.bat "%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Functions list\functions-template.bat" "Param2" "Param3"

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Parameters
:: 4. :Main
:: 5. :Footer

REM Bugfix: Use "REM ECHO DEBUG*ING: " instead of "::ECHO DEBUG*ING: " to comment-out debugging lines, in case any are within IF statements.
REM ECHO DEBUGGING: Begin RunAsAdministrator block.

:RunAsAdministrator
:: SS64 Run with elevated permissions script (ElevateMe.vbs)
:: Thanks to: http://ss64.com/vb/syntax-elevate.html
:-------------------------------------------------------------------------------
:: First check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 GOTO START

::GOTO START & REM <-- Leave this line in to always skip Elevation Prompt -->
::GOTO NOCHOICE & REM <-- Leave this line in to always Elevate to Administrator (skip choice) -->
ECHO:
ECHO CHOICE Loading...
ECHO:
:: https://ss64.com/nt/choice.html
CHOICE /M "Run as Administrator?"
IF ERRORLEVEL 2 GOTO START & REM No.
IF ERRORLEVEL 1 REM Yes.
:NOCHOICE

:: wait 2 seconds, in case this user is not in Administrators group. (To prevent an infinite loop of UAC admin requests on a restricted user account.)
ECHO Requesting administrative privileges... ^(waiting 2 seconds^)
PING -n 3 127.0.0.1 > nul

::Create and run a temporary VBScript to elevate this batch file
	:: https://ss64.com/nt/syntax-args.html
	SET _batchFile=%~s0
	SET _batchFile=%~f0
	SET _Args=%*
	IF NOT [%_Args%]==[] (
		REM double up any quotes
		REM https://ss64.com/nt/syntax-replace.html
		SET "_Args=%_Args:"=""%"
		REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	)
	:: https://ss64.com/nt/if.html
	IF ["%_Args%"] EQU [""] ( 
		SET "_CMD_RUN=%_batchFile%"
	) ELSE ( 
		SET "_CMD_RUN=""%_batchFile%"" %_Args%"
	)
	:: https://ss64.com/vb/shellexecute.html
	ECHO Set UAC = CreateObject^("Shell.Application"^) > "%Temp%\~ElevateMe.vbs"
	ECHO UAC.ShellExecute "CMD", "/C ""%_CMD_RUN%""", "", "RUNAS", 1 >> "%Temp%\~ElevateMe.vbs"
	:: ECHO UAC.ShellExecute "CMD", "/K ""%_batchFile% %_Args%""", "", "RUNAS", 1 >> "%temp%\~ElevateMe.vbs"

	cscript "%Temp%\~ElevateMe.vbs" 
	EXIT /B

:START
:: set the current directory to the batch file location
::CD /D %~dp0
:-------------------------------------------------------------------------------
:: End Run-As-Administrator function

:Header
::GOTO SkipHeader & REM Un-comment this line to skip Header
::ECHO:
REM ECHO DEBUGGING: Script name ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
REM ECHO DEBUGGING: Working directory: %~dp0 & REM The drive letter and path of this script's location.
REM ECHO DEBUGGING: Current directory: %CD% & REM The path of the currently selected directory.
::ECHO:

:: Check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 (
	REM ECHO DEBUGGING: Elevated Permissions: YES
) ELSE ( 
	REM ECHO DEBUGGING: Elevated Permissions: NO
	REM -------------------------------------------------------------------------------
	REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	REM Bugfix: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
)

REM ECHO DEBUGGING: Input parameters [%1] [%2] [%3] ...
::ECHO:
::PAUSE
::CLS
:SkipHeader

:: End Header

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin Parameters block.

:Parameters

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = Script to Debug

SET "_BatchPath=%~1" & REM %~1   Expand %1 removing any surrounding quotes (")
SET "_BatchPath=.\Install-AllWindowsUpdates.bat"
REM e.g. "%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Functions list\functions-template.bat"
SET "_BatchPath=%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Functions list\functions-template.bat"
REM SET "_BatchPath=%USERPROFILE%\Documents\SpiderOak Hive\SysAdmin\Flash Drive\General Flash Drive\Launch-AD_ElevatedCMD.bat"
SET "_BatchPath=%USERPROFILE%\Documents\Hg\Resume\Portfolio Finals\Sanitize-PDF.bat"
::SET "_BatchPath=.\Sanitize-PDF.bat"
SET "_BatchPath=%USERPROFILE%\Documents\GitHub\Batch-Tools-SysAdmin\Call-Test.bat"
SET "_BatchPath=%USERPROFILE%\Documents\GitHub\Batch-Tools-SysAdmin\Remote Access\Access-AdministrativeShare.bat"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = Options/Parameters to pass to Script

SET "_Options="

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 2: Execute script
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate Parameters
::===============================================================================

ECHO(
IF "%~1"=="" (
	REM No input parameters were given.
	REM Use hard-coded script location
	SET "DebugScript=%_BatchPath%"
	ECHO Script-coded locaation selected.
	ECHO:
) ELSE (
	REM Use input parameters.
	SET "DebugScript=%~1"
	ECHO Commandline parameter input selected. ^(drag-n-drop mode^)
	ECHO:
	REM >-------------------------------------------------------------------------------
	REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	REM Bugfix: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
)

::-------------------------------------------------------------------------------

IF NOT EXIST "%DebugScript%" (
	ECHO:
	ECHO "%DebugScript%" does not exist.
	ECHO:
	PAUSE
	GOTO END
)

::-------------------------------------------------------------------------------

::===============================================================================
:: Phase 2: Execute script
::===============================================================================

ECHO Launching script in DEBUG mode: 
ECHO(
ECHO %DebugScript%
ECHO(

ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO(
PAUSE
ECHO(
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO(

CMD /K "%DebugScript%"

ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO End %DebugScript%
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------
ECHO -------------------------------------------------------------------------------

::-------------------------------------------------------------------------------

:Footer
:END
ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.
