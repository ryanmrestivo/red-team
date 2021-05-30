@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Main
:: 4. :Footer

REM Bugfix: Use "REM ECHO DEBUG*ING: " instead of "::ECHO DEBUG*ING: " to comment-out debugging lines, in case any are within IF statements.
REM ECHO DEBUGGING: Begin RunAsAdministrator block.

:RunAsAdministrator
:: SS64 Run with elevated permissions script (ElevateMe.vbs)
:: Thanks to: http://ss64.com/vb/syntax-elevate.html
:-------------------------------------------------------------------------------
:: First check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 GOTO START

GOTO START & REM <-- Leave this line in to always skip Elevation Prompt -->
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
GOTO SkipHeader & REM Un-comment this line to skip Header
CLS
ECHO:
ECHO Script name ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location. NOTE: This will always return the path this script is in.
ECHO Current directory: %CD% & REM The path of the currently selected directory. NOTE: If this script is called from another location, this will return that selected path.
ECHO:

:: Check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 (
	ECHO Elevated Permissions: YES
) ELSE ( 
	ECHO Elevated Permissions: NO
	REM -------------------------------------------------------------------------------
	REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	REM Bugfix: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
)

::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM Bugfix: Check if we have admin rights right now (even tho we may not need them), so that later functions can check the result without requiring EnableDelayedExpansion to be enabled.
REM ECHO DEBUGGING: _GOT_ADMIN = '%_GOT_ADMIN%'
::https://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights
NET SESSION >nul 2>&1 && SET "_GOT_ADMIN=YES"
NET SESSION >nul 2>&1 || SET "_GOT_ADMIN=NO"
REM ECHO DEBUGGING: _GOT_ADMIN = '%_GOT_ADMIN%'
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ECHO:
ECHO Input parameters [%1] [%2] [%3] ...
ECHO:
::PAUSE
::CLS
:SkipHeader

:: End Header

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Show WLAN profiles, and get which name (SSID) to use
:: Phase 2: Get WLAN profile Key (passowrd) for SSID
:: Phase 3: Check if command success
:: Phase 4: Check if command failure
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Show WLAN profiles, and get which name to use
::===============================================================================

CLS
::ECHO Get stored Wifi password from SSID:

netsh wlan show profile

SET /P "_SSID=Enter SSID name: "

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 2: Get WLAN profile Key (passowrd) for SSID
::===============================================================================

IF EXIST "%_TEXT_OUTPUT_FILE%" DEL /Q "%_TEXT_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.

SET "_TEXT_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"

netsh wlan show profile "%_SSID%" key=clear >"%_TEXT_OUTPUT_FILE%" 2>"%_ERROR_OUTPUT_FILE%" 

netsh wlan show profile "%_SSID%" key=clear && SET "_COMMAND_EXIT=SUCCESS" || SET "_COMMAND_EXIT=FAILURE"
REM ECHO DEBUGGING: %%_COMMAND_EXIT%% = %_COMMAND_EXIT%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 3: Check if command success
::===============================================================================

IF "%_COMMAND_EXIT%"=="SUCCESS" (
	REM If command succeeds:
	REM ECHO DEBUGGING: Command succeeded^^!
	ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	TYPE "%_TEXT_OUTPUT_FILE%" | FIND "Key Content"
	REM ECHO DEBUGGING: ErrorLevel = !ERRORLEVEL!
	IF !ERRORLEVEL! NEQ 0 ECHO No password found.
	
	REM FIND "Key Content" <"%_TEXT_OUTPUT_FILE%"
	REM ECHO DEBUGGING: ErrorLevel = !ERRORLEVEL!
	REM IF !ERRORLEVEL! NEQ 0 ECHO No password found.
	ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	DEL /Q "%_TEXT_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
)
IF EXIST "%_TEXT_OUTPUT_FILE%" DEL /Q "%_TEXT_OUTPUT_FILE%" & REM Clean-up temp file ASAP.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 4: Check if command failure
::===============================================================================

REM Bugfix: always include "tokens=*" to handle filenames with spaces.
SET "_FILE_SIZE="
FOR /F "tokens=*" %%G IN ("%_ERROR_OUTPUT_FILE%") DO SET "_FILE_SIZE=%%~zG"
REM ECHO DEBUGGING: "%%_FILE_SIZE%%" = "%_FILE_SIZE%"

IF "%_COMMAND_EXIT%"=="FAILURE" (
	REM If command fails:
	REM ECHO DEBUGGING: Command failed^^!
	ECHO:
	IF %_FILE_SIZE% GTR 0 (
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		ECHO:
	) ELSE (
		REM ECHO DEBUGGING: No error msg found.
	)
	DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
	PAUSE
	GOTO Main
)
IF EXIST "%_TEXT_OUTPUT_FILE%" DEL /Q "%_TEXT_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::ECHO:
::ECHO -------------------------------------------------------------------------------

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:Footer
:END
ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.


