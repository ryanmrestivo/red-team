@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Parameters
:: 4. :ExternalFunctions
:: 5. :Main
:: 6. :DefineFunctions
:: 7. :Footer

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
ECHO:
ECHO Input parameters [%1] [%2] [%3] ...
ECHO:
::PAUSE
CLS
:SkipHeader

:: End Header

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin Parameters block.

:Parameters

:: Input from 

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = File A

SET "_FILE_A=%UserProfile%\Documents\SpiderOak Hive\SysAdmin\Tools\Compare To\CompareTo-Parent.bat"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = File B

SET "_FILE_B=%UserProfile%\Documents\SpiderOak Hive\SysAdmin\Configuring Systems\Boxstarter\Troubleshoot-BatchScript-CompareTo.bat"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin ExternalFunctions block.

:ExternalFunctions
:: Load External functions and programs:

::Index of external functions: 
:: 1. choco.exe "%_CHOCO_INSTALLED%"
:: 2. PSCP.EXE"%_PSCP_EXE%"
:: 3. kdiff3.exe "%_KDIFF_EXE%"
:: 4. CompareTo-Parent.bat "%_COMPARE_FUNC%"
:: 5. Banner.cmd "%_BANNER_FUNC%"
:: 6. fossil.exe "%_FOSSIL_EXE%"

::choco.exe
:-------------------------------------------------------------------------------
::IF /I "%_CHOCO_INSTALLED%"=="YES" choco upgrade javaruntime -y
::-------------------------------------------------------------------------------
::SET "_CHOCO_INSTALLED=YES"
SET "_CHOCO_INSTALLED=NO"
::SET "_QUIET_ERRORS=NO"
SET "_QUIET_ERRORS=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Test: check if fake "choc" command fails. Redirect all text & error output to NULL (supress all output)
::choc /? >nul 2>&1 && ECHO "Choc" command exists?^!?^!
::choc /? >nul 2>&1 || ECHO "Choc" command does NOT exist^! ^(TEST SUCCESS^)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the choco help command succeeds. Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
choco /? >nul 2>&1 && SET "_CHOCO_INSTALLED=YES" & REM ECHO choco.exe help command succeeded. & REM choco help command returned success.
choco /? >nul 2>%_ERROR_OUTPUT_FILE% || (
	REM SET "_CHOCO_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO choco.exe help command failed. & REM choco help command failed.
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		ECHO:
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if %ChocolateyInstall% directory exists ($env:ChocolateyInstall for PowerShell)
IF EXIST "%ChocolateyInstall%" (
	SET "_CHOCO_INSTALLED=YES"
	REM ECHO "ChocolateyInstall" directory exists. 
	REM ECHO e.g. %%ChocolateyInstall%% or $env:ChocolateyInstall
) ELSE (
	REM SET "_CHOCO_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO "ChocolateyInstall" directory does NOT exist. 
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:-------------------------------------------------------------------------------

::PSCP.EXE
:-------------------------------------------------------------------------------
::"%_PSCP_EXE%" (help function is just the command alone)
::IF "%_PSCP_INSTALLED%"=="YES" "%_PSCP_EXE%"
::GOTO SkipPscpFunction
::-------------------------------------------------------------------------------
SET "_PSCP_INSTALLED=NO"
SET "_QUIET_ERRORS=NO"
::SET "_QUIET_ERRORS=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the just the command succeeds (same as help function in this case). Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
pscp >nul 2>&1 && SET "_PSCP_INSTALLED=YES" & SET "_PSCP_EXE=pscp" & REM ECHO pscp help command succeeded. & REM pscp help command returned success.
pscp >nul 2>%_ERROR_OUTPUT_FILE% || (
	REM SET "_PSCP_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO pscp help command failed. & REM pscp help command failed.
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		ECHO:
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the just the command.exe succeeds (same as help function in this case). Redirect text output to NULL but redirect error output to temp file.
IF "%_PSCP_INSTALLED%"=="NO" (
	SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
	pscp.exe >nul 2>&1 && SET "_PSCP_INSTALLED=YES" & SET "_PSCP_EXE=pscp.exe" & REM ECHO pscp.exe help command succeeded. & REM pscp.exe help command returned success.
	pscp.exe >nul 2>%_ERROR_OUTPUT_FILE% || (
		REM SET "_PSCP_INSTALLED=NO"
		IF /I NOT "%_QUIET_ERRORS%"=="YES" (
			ECHO pscp.exe help command failed. & REM pscp.exe help command failed.
			ECHO Error output text:
			ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			TYPE "%_ERROR_OUTPUT_FILE%"
			ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			ECHO:
		)
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: C:\ProgramData\chocolatey\bin\PSCP.EXE
IF "%_PSCP_INSTALLED%"=="NO" SET "_PSCP_EXE=%ChocolateyInstall%\bin\PSCP.EXE"
IF EXIST "%_PSCP_EXE%" SET "_PSCP_INSTALLED=YES"
:: C:\ProgramData\chocolatey\lib\putty.portable\tools\PSCP.EXE
IF "%_PSCP_INSTALLED%"=="NO" SET "_PSCP_EXE=%ChocolateyInstall%\lib\putty.portable\tools\PSCP.EXE"
IF EXIST "%_PSCP_EXE%" SET "_PSCP_INSTALLED=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF "%_QUIET_ERRORS%"=="NO" (
	IF NOT EXIST "%_PSCP_EXE%" (
		ECHO:
		ECHO EXTERNAL FUNCTION NOT FOUND
		ECHO -------------------------------------------------------------------------------
		ECHO ERROR: Cannot find PSCP.EXE
		REM ECHO %_PSCP_EXE%
		ECHO:
		ECHO Have you installed PuTTY? ^(contains PSCP^)
		ECHO:
		ECHO Chocolatey ^(Run As Administrator^)
		ECHO ^> choco install putty -y
		ECHO:
		ECHO https://chocolatey.org/packages/putty
		ECHO:
		ECHO http://www.chiark.greenend.org.uk/~sgtatham/putty/
		ECHO -------------------------------------------------------------------------------
		ECHO:
		PAUSE
		ECHO:
		GOTO END
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: pscp.exe
:: "%_PSCP_EXE%"
:SkipPscpFunction
:-------------------------------------------------------------------------------

::kdiff3.exe
:-------------------------------------------------------------------------------
::"%_KDIFF_EXE%" -help
::"%_KDIFF_EXE%" "%_FILE_A%" "%_FILE_B%"
GOTO SkipKdiffFunction
::-------------------------------------------------------------------------------
:: Just the command
SET "_KDIFF_EXE=kdiff3.exe"
:: C:\Program Files\TortoiseHg\lib\kdiff3.exe
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_KDIFF_EXE=%ProgramFiles%\TortoiseHg\lib\kdiff3.exe"
)
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_KDIFF_EXE=%ProgramFiles(x86)%\TortoiseHg\lib\kdiff3.exe"
)
:: C:\Program Files\KDiff3\kdiff3.exe
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_KDIFF_EXE=%ProgramFiles%\KDiff3\kdiff3.exe"
)
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_KDIFF_EXE=%ProgramFiles(x86)%\KDiff3\kdiff3.exe"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF NOT EXIST "%_KDIFF_EXE%" (
	ECHO:
	ECHO EXTERNAL FUNCTION NOT FOUND
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find kdiff3.exe
	REM ECHO %_KDIFF_EXE%
	ECHO:
	ECHO Have you installed TortoiseHg or KDiff3?
	ECHO:
	ECHO Chocolatey ^(Run As Administrator^)
	ECHO ^> choco install tortoisehg -y ^(or^)
	ECHO ^> choco install kdiff3 -y
	ECHO:
	ECHO https://chocolatey.org/packages/kdiff3
	ECHO:
	ECHO http://kdiff3.sourceforge.net/
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
)
:: kdiff3.exe -help
:: "%_KDIFF_EXE%" -help
:SkipKdiffFunction
:-------------------------------------------------------------------------------

::CompareTo-Parent.bat
:-------------------------------------------------------------------------------
::CALL "%_COMPARE_FUNC%" "%_FILE_A%" "%_FILE_B%"
:: Requires SETLOCAL EnableDelayedExpansion
GOTO SkipCompareToParentFunc
::-------------------------------------------------------------------------------
::SET "_COMPAREFUNC_FOUND=YARP"
SET "_COMPAREFUNC_FOUND=NOPE"
::SET "_ORIG_DIR=%CD%"
SET "_ORIG_DIR=%~dp0"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Just the command
SET "_COMPARE_FUNC=CompareTo-Parent.bat"
:: Same directory
IF NOT EXIST "%_COMPARE_FUNC%" (
	SET "_COMPARE_FUNC=%CD%\CompareTo-Parent.bat"
)
:: One directory down
IF NOT EXIST "%_COMPARE_FUNC%" (
	SET "_COMPARE_FUNC=%CD%\Compare To\CompareTo-Parent.bat"
)
:: Two directories down
IF NOT EXIST "%_COMPARE_FUNC%" (
	SET "_COMPARE_FUNC=%CD%\Tools\Compare To\CompareTo-Parent.bat"
)
:: SodaLake Flash Drive relative path
IF NOT EXIST "%_COMPARE_FUNC%" (
	CD ..
	CD ..
	SET "_COMPARE_FUNC=!CD!\Tools\Compare To\CompareTo-Parent.bat"
	CD %_ORIG_DIR%
)
:: Flash Drive Updates relative path
IF NOT EXIST "%_COMPARE_FUNC%" (
	CD ..
	SET "_COMPARE_FUNC=!CD!\SodaLake\Tools\Compare To\CompareTo-Parent.bat"
	CD %_ORIG_DIR%
)
:: SpiderOak Hive location
IF NOT EXIST "%_COMPARE_FUNC%" (
	REM SET "_COMPARE_FUNC=%USERPROFILE%\Documents\__\SodaLake\Tools\Compare To\CompareTo-Parent.bat"
	SET "_COMPARE_FUNC=%USERPROFILE%\Documents\...\Tools\Compare To\CompareTo-Parent.bat"
)
:: Work Laptop location
IF NOT EXIST "%_COMPARE_FUNC%" (
	REM SET "_COMPARE_FUNC=%USERPROFILE%\Documents\__\Tools\Compare To\CompareTo-Parent.bat"
	SET "_COMPARE_FUNC=%USERPROFILE%\Documents\SodaLake\Tools\Compare To\CompareTo-Parent.bat"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF NOT EXIST "%_COMPARE_FUNC%" (
	SET "_COMPAREFUNC_FOUND=NOPE"
	ECHO:
	ECHO EXTERNAL FUNCTION NOT FOUND
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find CompareTo-Parent.bat
	ECHO %_COMPARE_FUNC%
	ECHO:
	ECHO %UserProfile%\Documents\SpiderOak Hive\SysAdmin\Tools\Compare To\CompareTo-Parent.bat
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
	GOTO SkipCompareToParentFunc
) ELSE (
	SET "_COMPAREFUNC_FOUND=YARP"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Script name & extention
FOR %%G IN ("%_COMPARE_FUNC%") DO SET "_COMPARE_FUNC_NAME=%%~nxG"

:: Script drive & path
FOR %%G IN ("%_COMPARE_FUNC%") DO SET "_COMPARE_FUNC_PATH=%%~dpG"
:SkipCompareToParentFunc
:-------------------------------------------------------------------------------

::Banner.cmd
:-------------------------------------------------------------------------------
::CALL "%_BANNER_FUNC%" 12345678901234
::CALL "%_BANNER_FUNC%" 123456789012345678901
::CALL "%_BANNER_FUNC%" A-Z, 0-9, . @
:: Maximum string length is 14. (For CMD)
:: Maximum string length is 21. (For PowerShell)
:: Compatible characters: 0-9 Hyphen "-" Period "." Comma "," At "@" A-Z (Caps only) Space " "
:: Requires SETLOCAL EnableDelayedExpansion
::-------------------------------------------------------------------------------
::SET "_BANNER_FOUND=YARP"
SET "_BANNER_FOUND=NOPE"
SET "_ORIG_DIR=%CD%"
SET "_ORIG_DIR=%~dp0"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Just the command
SET "_BANNER_FUNC=Banner.cmd"
:: Same directory
IF NOT EXIST "%_BANNER_FUNC%" (
	SET "_BANNER_FUNC=%CD%\Banner.cmd"
)
:: One directory down
IF NOT EXIST "%_BANNER_FUNC%" (
	SET "_BANNER_FUNC=%CD%\Banner\Banner.cmd"
)
:: One directory up
IF NOT EXIST "%_BANNER_FUNC%" (
	CD ..
	SET "_BANNER_FUNC=!CD!\Banner.cmd"
	CD %_ORIG_DIR%
)
:: One directory up, into functions folder
IF NOT EXIST "%_BANNER_FUNC%" (
	CD ..
	SET "_BANNER_FUNC=!CD!\functions\Banner.cmd"
	CD %_ORIG_DIR%
)
:: Two directories up
IF NOT EXIST "%_BANNER_FUNC%" (
	CD ..
	CD ..
	SET "_BANNER_FUNC=!CD!\Banner.cmd"
	CD %_ORIG_DIR%
)
:: SodaLake Flash Drive relative path
IF NOT EXIST "%_BANNER_FUNC%" (
	CD ..
	SET "_BANNER_FUNC=!CD!\Banner\Banner.cmd"
	CD %_ORIG_DIR%
)
IF NOT EXIST "%_BANNER_FUNC%" (
	CD ..
	CD ..
	SET "_BANNER_FUNC=!CD!\Batch\Banner\Banner.cmd"
	CD %_ORIG_DIR%
)
:: SpiderOak Hive location
IF NOT EXIST "%_BANNER_FUNC%" (
	REM SET "_BANNER_FUNC=%USERPROFILE%\Documents\__\Banner\Banner.cmd"
	SET "_BANNER_FUNC=%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Banner\Banner.cmd"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF NOT EXIST "%_BANNER_FUNC%" (
	SET "_BANNER_FOUND=NOPE"
	ECHO:
	ECHO EXTERNAL FUNCTION NOT FOUND
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find Banner.cmd
	ECHO %_BANNER_FUNC%
	ECHO:
	ECHO https://ss64.com/nt/syntax-banner.html
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
	GOTO SkipBannerFunc
) ELSE (
	SET "_BANNER_FOUND=YARP"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Script name & extention
FOR %%G IN ("%_BANNER_FUNC%") DO SET "_BANNER_FUNC_NAME=%%~nxG"

:: Script drive & path
FOR %%G IN ("%_BANNER_FUNC%") DO SET "_BANNER_FUNC_PATH=%%~dpG"
:SkipBannerFunc
:-------------------------------------------------------------------------------

::fossil.exe
:-------------------------------------------------------------------------------
::"%_FOSSIL_EXE%" help
::"%_FOSSIL_EXE%" help ui
::"%_FOSSIL_EXE%" ui "%_FOSSIL_FILE%"
GOTO SkipFossilFunction
::-------------------------------------------------------------------------------
:: Just the command
SET "_FOSSIL_EXE=fossil"
:: Just the command + extension
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_FOSSIL_EXE=fossil.exe"
)
:: C:\ProgramData\chocolatey\lib\fossil.portable\tools\fossil.exe
IF NOT EXIST "%_KDIFF_EXE%" (
	SET "_FOSSIL_EXE=%ChocolateyInstall%\lib\fossil.portable\tools\fossil.exe"
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF NOT EXIST "%_FOSSIL_EXE%" (
	ECHO:
	ECHO EXTERNAL FUNCTION NOT FOUND
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find fossil.exe
	ECHO %_FOSSIL_EXE%
	ECHO:
	ECHO Have you installed Fossil?
	ECHO:
	ECHO Chocolatey ^(Run As Administrator^)
	ECHO ^> choco install fossil -y
	ECHO:
	ECHO https://chocolatey.org/packages/fossil
	ECHO:
	ECHO https://www.fossil-scm.org/
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
)
:: fossil.exe help
:: "%_FOSSIL_EXE%" help
:SkipFossilFunction
:-------------------------------------------------------------------------------

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 2: Test :GetIfPathIsDriveRoot
:: Phase 3: Test :GetWindowsVersion
:: Phase 4: Test Banner.cmd (external function)
:: Phase 5: Test :GetTerminalWidth
:: Phase 6: Test :CheckLink
:: Phase 7: Test :GetDate, :ConvertTimeToSeconds, and :ConvertSecondsToTime
:: Phase 8: Test :InitLog and :InitLogOriginal
:: Phase 9: Test :CreateShortcut, :CreateSymbolicLink, and :CreateSymbolicDirLink
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate Parameters
::===============================================================================

:: Always prefer parameters passed via command line over hard-coded vars.
SET "_CALLED_FROM_SCRIPT=DISABLED"
IF NOT "%~1"=="" (
	SET "_CALLED_FROM_SCRIPT=ACTIVE"
)

IF /I NOT "%_CALLED_FROM_SCRIPT%"=="ACTIVE" CLS

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Activate help function
IF NOT "%~1"=="" (
	REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	IF /I "%~1"=="help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="-h" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="-help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="--help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/?" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/h" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
	IF /I "%~1"=="/help" (
		CALL :DisplayHelp
		GOTO END
		REM ENDLOCAL & EXIT /B
	)
)

REM ECHO DEBUGGING: Finished help evaluation.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Get _FILE_A Name & eXtention, Drive letter & Path
FOR %%G IN ("%_FILE_A%") DO SET "_FILE_A_NAME=%%~nxG"
FOR %%G IN ("%_FILE_A%") DO SET "_FILE_A_PATH=%%~dpG"

:: Get _FILE_B Name & eXtention, Drive letter & Path
FOR %%G IN ("%_FILE_B%") DO SET "_FILE_B_NAME=%%~nxG"
FOR %%G IN ("%_FILE_B%") DO SET "_FILE_B_PATH=%%~dpG"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Find if _FILE_A has a wildcard "*" in it.
:: "%_Variable:_SearchString=_ReplacementString%"
::SET "_FILE_A=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\*.bat"
::SET "_FILE_A=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\CompareTo-Parent.bat"
REM ECHO DEBUGGING: _FILE_A = "%_FILE_A%"
IF /I NOT "%_FILE_A:**=%"=="%_FILE_A%" (
	REM _FILE_A contains an asterisk.
	SET "_FILE_A_WILDCARD=ENABLED"
) ELSE (
	REM _FILE_A does NOT contain an asterisk.
	SET "_FILE_A_WILDCARD=DISABLED"
)
REM ECHO DEBUGGING: _FILE_A_WILDCARD = %_FILE_A_WILDCARD%

:: Find if _FILE_B has a wildcard "*" in it.
:: "%_Variable:_SearchString=_ReplacementString%"
::SET "_FILE_B=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\*.bat"
::SET "_FILE_B=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\CompareTo-Parent.bat"
REM ECHO DEBUGGING: _FILE_B = "%_FILE_B%"
IF /I NOT "%_FILE_B:**=%"=="%_FILE_B%" (
	REM _FILE_B contains an asterisk.
	SET "_FILE_B_WILDCARD=ENABLED"
) ELSE (
	REM _FILE_B does NOT contain an asterisk.
	SET "_FILE_B_WILDCARD=DISABLED"
)
REM ECHO DEBUGGING: _FILE_B_WILDCARD = %_FILE_B_WILDCARD%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 2: Test :GetIfPathIsDriveRoot
::===============================================================================








:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:: <-- Footer could also go here -->

:: End Footer

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin DefineFunctions block.

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :SampleFunction
:: 2. :DisplayHelp
:: 3. :GetTerminalWidth
:: 4. :StrLen
:: 5. :GenerateBlankSpace
:: 6. :FormatTextLine
:: 7. :CheckLink
:: 8. :GetWindowsVersion
:: 9. :GetIfPathIsDriveRoot
:: 10. :CreateShortcut
:: 11. :CreateSymbolicLink
:: 12. :CreateSymbolicDirLink
:: 13. :GetDate
:: 14. :ConvertTimeToSeconds
:: 15. :ConvertSecondsToTime
:: 16. :InitLogOriginal
:: 17. :InitLog
:: 18. :SplashLogoKdiff
:: 19. :SplashLogoMerge
:: 20. :SplashLogoMergeComplete

GOTO SkipFunctions
:-------------------------------------------------------------------------------
:SampleFunction RequiredParam [OptionalParam]
:: Dependences: other functions this one is dependent on.
:: Description for SampleFunction's purpose & ability.
:: Description of RequiredParam and OptionalParam.
:: Outputs:
:: "%_SAMPLE_OUTPUT_1%"
:: "%_SAMPLE_OUTPUT_2%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_required_param=%1"
SET "_optional_param=%2"
:: Also works: IF [%1]==[] (
IF [!_required_param!]==[] (
	ECHO ERROR in SampleFunction^! No Required Parameter.
	ECHO:
	PAUSE
	ENDLOCAL
	EXIT /B
)
:: Also works: IF [%2]==[] (
IF [!_optional_param!]==[] (
	REM https://ss64.com/nt/syntax-args.html
	SET "_use_optional=NOPE."
) ELSE (
	SET "_use_optional=YUP."
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Do things here.

SET "_result=%_required_param%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_SAMPLE_OUTPUT_1=%_result%" & SET "_SAMPLE_OUTPUT_2=%_use_optional%"
EXIT /B
:-------------------------------------------------------------------------------
:DisplayHelp
::CALL :DisplayHelp
:: Display help splash text.
@ECHO OFF
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::C:\Users\[Username]>ipconfig /?
::
::USAGE:
::    ipconfig [/allcompartments] [/? | /all |
::                                 /renew [adapter] | /release [adapter] |
::                                 /renew6 [adapter] | /release6 [adapter] |
::                                 /flushdns | /displaydns | /registerdns |
::                                 /showclassid adapter |
::                                 /setclassid adapter [classid] |
::                                 /showclassid6 adapter |
::                                 /setclassid6 adapter [classid] ]
::
::where
::    adapter             Connection name
::                       (wildcard characters * and ? allowed, see examples)
::
::    Options:
::       /?               Display this help message
::       /all             Display full configuration information.
::       /release         Release the IPv4 address for the specified adapter.
::       /release6        Release the IPv6 address for the specified adapter.
::       /renew           Renew the IPv4 address for the specified adapter.
::       /renew6          Renew the IPv6 address for the specified adapter.
::       /flushdns        Purges the DNS Resolver cache.
::       /registerdns     Refreshes all DHCP leases and re-registers DNS names
::       /displaydns      Display the contents of the DNS Resolver Cache.
::       /showclassid     Displays all the dhcp class IDs allowed for adapter.
::       /setclassid      Modifies the dhcp class id.
::       /showclassid6    Displays all the IPv6 DHCP class IDs allowed for adapter.
::       /setclassid6     Modifies the IPv6 DHCP class id.
::
::
::The default is to display only the IP address, subnet mask and
::default gateway for each adapter bound to TCP/IP.
::
::For Release and Renew, if no adapter name is specified, then the IP address
::leases for all adapters bound to TCP/IP will be released or renewed.
::
::For Setclassid and Setclassid6, if no ClassId is specified, then the ClassId is removed.
::
::Examples:
::    > ipconfig                       ... Show information
::    > ipconfig /all                  ... Show detailed information
::    > ipconfig /renew                ... renew all adapters
::    > ipconfig /renew EL*            ... renew any connection that has its
::                                         name starting with EL
::    > ipconfig /release *Con*        ... release all matching connections,
::                                         eg. "Wired Ethernet Connection 1" or
::                                             "Wired Ethernet Connection 2"
::    > ipconfig /allcompartments      ... Show information about all
::                                         compartments
::    > ipconfig /allcompartments /all ... Show detailed information about all
::                                         compartments
::
::C:\Users\[Username]>_
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::C:\Users\[Username]>tracert /?
::
::Usage: tracert [-d] [-h maximum_hops] [-j host-list] [-w timeout]
::               [-R] [-S srcaddr] [-4] [-6] target_name
::
::Options:
::    -d                 Do not resolve addresses to hostnames.
::    -h maximum_hops    Maximum number of hops to search for target.
::    -j host-list       Loose source route along host-list (IPv4-only).
::    -w timeout         Wait timeout milliseconds for each reply.
::    -R                 Trace round-trip path (IPv6-only).
::    -S srcaddr         Source address to use (IPv6-only).
::    -4                 Force using IPv4.
::    -6                 Force using IPv6.
::
::C:\Users\[Username]>_
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ECHO:
::ECHO ===============================================================================
::ECHO %~nx0 Help.
::ECHO:
::ECHO Called from: "%~dp0"
::ECHO:
::ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO:
ECHO USAGE: .\%~nx0 "path_to_file_a" "path_to_file_b" [banner]
ECHO:
ECHO where
ECHO     banner      =       QUIET - for minimal output
ECHO                         SIMPLE - for a small banner during start.
ECHO                         FANCY - for a custom banner during start ^& end.
ECHO                        (If no option is selected, the default is FANCY.)
ECHO:
::ECHO OPTIONS:
::ECHO:
ECHO Uses kdiff3 to merge changes between two different files or folders.
ECHO Paramters can be passed via command line or hard-coded into this script.
ECHO If no parameters are provided, default is to use hard-coded variables.
ECHO:
ECHO You may also drag-and-drop files on this script one at a time.
ECHO:
ECHO EXAMPLES:
ECHO     > .\%~nx0 "^%USERPROFILE^%\Documents\file_1.txt" "^%USERPROFILE^%\Dropbox\file_1.txt"
ECHO:
ECHO     > .\%~nx0 "^%USERPROFILE^%\Documents\Folder1" "^%USERPROFILE^%\Dropbox\Folder1" fancy
ECHO:
ECHO     > .\%~nx0 "^%USERPROFILE^%\Desktop\file_2.json" "^%USERPROFILE^%\Dropbox\file_2.json" quiet
ECHO:
::ECHO     > ipconfig                       ... Show information
::ECHO     > ipconfig /all                  ... Show detailed information
::ECHO     > ipconfig /renew                ... renew all adapters
::ECHO     > ipconfig /renew EL*            ... renew any connection that has its
::ECHO                                          name starting with EL
::ECHO     > ipconfig /release *Con*        ... release all matching connections,
::ECHO                                          eg. "Wired Ethernet Connection 1" or
::ECHO                                              "Wired Ethernet Connection 2"
::ECHO     > ipconfig /allcompartments      ... Show information about all
::ECHO                                          compartments
::ECHO     > ipconfig /allcompartments /all ... Show detailed information about all
::ECHO                                          compartments
::ECHO 
::ECHO EXAMPLE:
::ECHO .\%~nx0 "path_to_file_a" "path_to_file_b" [BANNER]
::ECHO:
::ECHO PARAMETERS:
::ECHO    "path_to_file_a"   - Full file path pointing to the first file.
::ECHO    "path_to_file_b"   - Full file path pointing to the second file.
::ECHO    [BANNER]           - If no option is selected, the default is FANCY.
::ECHO                           + QUIET - for minimal output
::ECHO                           + SIMPLE - for a small banner during start.
::ECHO                           + FANCY - for a custom banner during start ^& end.
::ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO:
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:GetTerminalWidth
::CALL :GetTerminalWidth
:: Get width in characters the current terminal (Command Prompt) is.
:: Thanks to:
:: https://ss64.com/nt/syntax-banner.html
:: Outputs:
:: "%_MAX_WINDOW_WIDTH%" Maximum length for a string e.g. "79" (CMD.EXE) or "119" (PowerShell)
:: "%_TRUE_WINDOW_WIDTH%" Actual terminal window width e.g. "80" (CMD.EXE) or "120" (PowerShell)
@ECHO OFF
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FOR /F "tokens=2" %%G IN ('mode ^|find "Columns"') DO SET /A _WINDOW_WIDTH=%%G
SET /A "_WINDOW_WIDTH_NO_NEWLINE=%_WINDOW_WIDTH%-1"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_MAX_WINDOW_WIDTH=%_WINDOW_WIDTH_NO_NEWLINE%" & SET "_TRUE_WINDOW_WIDTH=%_WINDOW_WIDTH%"
EXIT /B
:-------------------------------------------------------------------------------
:StrLen  StrVar  [RtnVar]
::CALL :StrLen "%_INPUT_STRING%" _STR_LEN_RTN
::ECHO %_STR_LEN_RTN%
:: Thanks to dbenham from StackOverflow:
::https://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file#5841587
::
:: Computes the length of string in variable StrVar
:: and stores the result in variable RtnVar.
:: If RtnVar is is not specified, then prints the length to stdout.
::
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(
  SETLOCAL EnableDelayedExpansion
  SET "s=A!%~1!"
  SET "len=0"
  FOR %%P IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
    IF "!s:~%%P,1!" NEQ "" (
      SET /A "len+=%%P"
      SET "s=!s:~%%P!"
    )
  )
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(
  ENDLOCAL
  IF "%~2" EQU "" (ECHO %len%) ELSE SET "%~2=%len%"
  EXIT /B
)
:-------------------------------------------------------------------------------
:GenerateBlankSpace NumberOfBlankSpaces
::CALL :GenerateBlankSpace "%_NUM_BLANK_LEN%"
::ECHO %_BLANK_SPACE%#
::ECHO 1234567890123456789012345678901234567890123456789012345678901234567890123456789
::ECHO 0        1         2         3         4         5         6         7         
::ECHO -------------------------------------------------------------------------------
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
SETLOCAL
SET "_INPUT_INT=%~1"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if input parameter exists.
IF [%_INPUT_INT%]==[] ECHO Function :GenerateBlankSpace requires an integer input paramter. & ENDLOCAL & EXIT /B
:: Check if input parameter is a number.
SET "_INT_TEST="&FOR /F "delims=0123456789" %%G IN ("%_INPUT_INT%") DO SET "_INT_TEST=%%G"
IF DEFINED _INT_TEST (
	REM ECHO %_INPUT_INT% is NOT numeric
	ECHO Function :GenerateBlankSpace requires an integer input paramter. & ENDLOCAL & EXIT /B
) ELSE (
	REM sECHO %_INPUT_INT% is numeric
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_OUTPUT_STRING="
::https://ss64.com/nt/for_l.html
FOR /L %%G IN (1,1,%_INPUT_INT%) DO SET "_OUTPUT_STRING=%_OUTPUT_STRING% "
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_BLANK_SPACE=%_OUTPUT_STRING%"
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:FormatTextLine InputText [PrefixBlankSpaces] [PrefixBorderCharacter] [SuffixBorderCharacter]
::CALL :FormatTextLine "%_TEXT_IN_BOX%" 2 ^( ^)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
SETLOCAL
SET "_TEXTBODY=%~1"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF /I [%~2]==[] (
	REM Default to 1 blank prefix space if none defined`
	SET "_PREFIX_BLANK=1"
) ELSE (
	SET "_PREFIX_BLANK=%~2"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if border character input parameter(s) were supplied
IF /I [%~3]==[] (
	REM No parameter 3 or 4, so set | as the default border character
	SET "_PREFIX_CHAR=^|"
	SET "_SUFFIX_CHAR=^|"
) ELSE (
	IF /I [%~4]==[] (
		REM Parameter 3 is present, but parameter 4 is not.
		REM Set both characters to the same.
		SET "_PREFIX_CHAR=%~3"
		SET "_SUFFIX_CHAR=%~3"
	) ELSE ( 
		REM Both paramter 3 and 4 are present, use what is provided.
		SET "_PREFIX_CHAR=%~3"
		SET "_SUFFIX_CHAR=%~4"
	)
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_BLANK_SPACE=%_OUTPUT_STRING%"
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:CheckLink IPorDNSaddress
:: Check address for ICMP ping response packets
:: http://stackoverflow.com/questions/3050898/how-to-check-if-ping-responded-or-not-in-a-batch-file
:: thanks to paxdiablo for checklink.cmd
@SETLOCAL EnableExtensions EnableDelayedExpansion
@ECHO OFF
SET "ipaddr=%1"
ECHO Testing address: %ipaddr%
SET "_loopcount=0"
:loop
SET "state=down"
FOR /F "tokens=5,7" %%a IN ('PING -n 1 !ipaddr!') DO (
    IF "x%%a"=="xReceived" IF "x%%b"=="x1," SET "state=up"
)
ECHO Link is !state!
REM --> test networking hardware capability
PING -n 6 127.0.0.1 >nul: 2>nul:
IF "!state!"=="down" (
	IF !_loopcount! LSS 3 (
		SET /A "_loopcount+=1"
		GOTO :loop
	) ELSE (
		ENDLOCAL & SET "_LinkState=%state%" & EXIT /B
	)	
) ELSE (
	IF "!state!"=="up" (
		ENDLOCAL & SET "_LinkState=%state%" & EXIT /B
	)
)
ENDLOCAL & SET "_LinkState=%state%"
EXIT /B
:-------------------------------------------------------------------------------
:GetWindowsVersion
@ECHO OFF
SETLOCAL
FOR /F "tokens=4-7 delims=[.] " %%i IN ('ver') DO (
	IF %%i == Version SET "_winversion=%%j.%%k"
	IF %%i neq Version SET "_winversion=%%i.%%j"
)	
IF "%_winversion%" == "10.0" (
	SET "_winversion=10"
	SET "_winvername=10"
	SET "_easyname=Windows 10"
	ECHO Windows 10
) ELSE (
	IF "%_winversion%" == "6.3" (
		SET "_winvername=8.1"
		SET "_easyname=Windows 8.1"
		ECHO Windows 8.1
	) ELSE (
		IF "%_winversion%" == "6.2" (
			SET "_winvername=8"
			SET "_easyname=Windows 8"
			ECHO Windows 8
		) ELSE (
			IF "%_winversion%" == "6.1" (
				SET "_winvername=7"
				SET "_easyname=Windows 7"
				ECHO Windows 7
			) ELSE (
				IF "%_winversion%" == "6.0" (
					SET "_winvername=Vista"
					SET "_easyname=Windows Vista"
					ECHO Windows Vista
				) ELSE (
					IF "%_winversion%" == "5.2" (
						SET "_winvername=Server 2003 / R2 / XP 64-bit"
						SET "_easyname=Windows Server 2003 / R2 / Windows XP 64-bit Edition"
						ECHO Windows Server 2003 / R2 / Windows XP 64-bit Edition
					) ELSE (
						IF "%_winversion%" == "5.1" (
							SET "_winvername=XP"
							SET "_easyname=Windows XP"
							ECHO Windows XP
						) ELSE (
							IF "%_winversion%" == "5.0" (
								SET "_winvername=2000"
								SET "_easyname=Windows 2000"
								ECHO Windows 2000
							) ELSE (
								REM SET "_winversion=0.0"
								SET "_winvername=Unknown"
								SET "_easyname=Unable to determine OS version automatically: %_winversion%"
								ECHO %_easyname%
							)
						)
					)
				)
			)
		)
	)
)
ENDLOCAL & SET "_WindowsVersion=%_winversion%" & SET "_WindowsName=%_winvername%" & SET "_WindowsEasyName=%_easyname%"
EXIT /B
:-------------------------------------------------------------------------------
:GetIfPathIsDriveRoot
::CALL :GetIfPathIsDriveRoot "%_PATH_TO_CHECK%"
::ECHO "%_IS_DRIVE_LETTER%"
::ECHO "%_DRIVE_LETTER_PATH%"
::Bugfix: If _DEST is just a drive letter e.g. G:\ robocopy will fail if it has quotes e.g. "G:\"
:: Outputs:
:: "%_IS_DRIVE_LETTER%" Returns if the input path is just a drive letter, e.g. "YES" or "NO"
:: "%_DRIVE_LETTER_PATH%" Returns 3-character drive path, e.g. "G:\" or "H:\"
@ECHO OFF
SETLOCAL
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_INPUT_STRING=%~1"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if string is longer than 3 characters
:: https://ss64.com/nt/syntax-substring.html
:: %variable:~num_chars_to_skip,num_chars_to_keep%
SET "_FOURTH_CHAR=%_INPUT_STRING:~3,1%"
IF "%_FOURTH_CHAR%"=="" (
	SET "_DRIVE_LETTER=YES"
) ELSE (
	SET "_DRIVE_LETTER=NO"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: If not drive letter, make it a drive letter
IF "%_DRIVE_LETTER%"=="NO" (
	REM Get the _INPUT_STRING drive letter
	FOR /F %%G IN ("%_INPUT_STRING%") DO (SET _SOURCE_LETT=%%~dG)
	REM Only works when _INPUT_STRING is not already a drive letter, such as: "G:\" or "G:" or "G" otherwise will return nothing/null
	REM Returns e.g. "G:"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF "%_DRIVE_LETTER%"=="NO" (
	SET "_LETTER_INPUT=%_SOURCE_LETT%"
) ELSE IF "%_DRIVE_LETTER%"=="YES" (
	SET "_LETTER_INPUT=%_INPUT_STRING%"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Make _LETTER_INPUT 3-characters
:: %variable:~num_chars_to_skip,num_chars_to_keep%
SET "_FIRST_CHAR=%_LETTER_INPUT:~0,1%"
SET "_DRIVE_LETTER_OUTPUT=%_FIRST_CHAR%:\"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_IS_DRIVE_LETTER=%_DRIVE_LETTER%" & SET "_DRIVE_LETTER_PATH=%_DRIVE_LETTER_OUTPUT%"
EXIT /B
:-------------------------------------------------------------------------------
:CreateShortcut
:: https://superuser.com/questions/455364/how-to-create-a-shortcut-using-a-batch-script
:: Windows does not have any native CMD or PowerShell tools to create shortcuts, but 
:: You can achieve this without external tools by creating a temporary VBScript:
@ECHO OFF
SETLOCAL
:: Shotcut Path must include an extension of either *.url (for internet shortcuts) or *.lnk (for file-system shortcuts)
SET "ShortcutPath=%~1" & REM %~1   Expand %1 removing any surrounding quotes (")
SET "ShortcutTarget=%~2"

SET SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"

ECHO Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
ECHO sLinkFile = "%ShortcutPath%" >> %SCRIPT%
ECHO Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
ECHO oLink.TargetPath = "%ShortcutTarget%" >> %SCRIPT%
ECHO oLink.Save >> %SCRIPT%

CScript /nologo %SCRIPT%
DEL %SCRIPT%

ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:CreateSymbolicLink
:: Always Run As Administrator
:: Symbolic Links are useful for fooling other programs into thinking the Symblink is really the file/directory that they point to.
:: In contrast, Shortcuts are actually files themselves (*.lnk) which must be navigated to reach their target.
:: Symbolic links can be ABSOLUTE or RELATIVE. This function will only make ABSOLUTE symblinks unless you escape the var % symbol (per cent sign). 
@ECHO OFF
SETLOCAL
SET "SymblinkPath=%~1" & REM %~1   Expand %1 removing any surrounding quotes (")
SET "SymblinkTarget=%~2"

:: C:\>HELP MKLINK
:: Creates a symbolic link.
:: 
:: MKLINK [[/D] | [/H] | [/J]] Link Target
:: 
::         /D      Creates a directory symbolic link.  Default is a file
::                 symbolic link.
::         /H      Creates a hard link instead of a symbolic link.
::         /J      Creates a Directory Junction.
::         Link    specifies the new symbolic link name.
::         Target  specifies the path (relative or absolute) that the new link
::                 refers to.

:: e.g. MKLINK C:\Users\G\Documents\mgsd.html "C:\Users\G\Documents\SpiderOak Hive\mgsd.html"

MKLINK "%SymblinkPath%" "%SymblinkTarget%"

ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:CreateSymbolicDirLink
:: Always Run As Administrator
:: Symbolic Links are useful for fooling other programs into thinking the Symblink is really the file/directory that they point to.
:: In contrast, Shortcuts are actually files themselves (*.lnk) which must be navigated to reach their target.
:: Symbolic links can be ABSOLUTE or RELATIVE. This function will only make ABSOLUTE symblinks unless you escape the var % symbol (per cent sign). 
@ECHO OFF
SETLOCAL
SET "SymblinkPath=%~1" & REM %~1   Expand %1 removing any surrounding quotes (")
SET "SymblinkTarget=%~2"

:: C:\>HELP MKLINK
:: Creates a symbolic link.
:: 
:: MKLINK [[/D] | [/H] | [/J]] Link Target
:: 
::         /D      Creates a directory symbolic link.  Default is a file
::                 symbolic link.
::         /H      Creates a hard link instead of a symbolic link.
::         /J      Creates a Directory Junction.
::         Link    specifies the new symbolic link name.
::         Target  specifies the path (relative or absolute) that the new link
::                 refers to.

:: e.g. MKLINK /d "C:\Users\Grant - Work\Dropbox" C:\Users\Grant\Dropboxs

MKLINK /D "%SymblinkPath%" "%SymblinkTarget%"

:: Deleting Symbolic Links
:: http://superuser.com/questions/167076/how-can-i-delete-a-symbolic-link#306618
:: Be very careful.
:: If you have a symbolic link that is a directory (made with MKLINK /D) then using DEL will delete all of the files in the target directory (the directory that the link points to), rather than just the link.
:: SOLUTION: RMDIR on the other hand will only delete the directory link, not what the link points to.

ENDLOCAL
EXIT /B
:-------------------------------------------------------------------------------
:GetDate
:: Get an alphabetically sortable date, returned in a var, in yyyy-mm-dd format.
:: For convienence also get a path returned of "C:\Home Path\this script_yyyy-mm-dd.log" in a var
:: Outputs:
:: "%_SORTABLE_DATE%" (will always be exactly 10 characters long) e.g. 2018-01-28
:: "%_SORTABLE_TIME%" (will always be exactly 8 characters long) e.g. 21-31-39 or 01-57-25
:: "%_FORMATTED_TIME%" (will always be exactly 11 characters long) e.g. " 9:31:39 PM"
:: "%_SORTABLE_DATE_PATH%" e.g. "C:\Home Path\this script_yyyy-mm-dd.log"
:: "%_SORTABLE_DATETIME_PATH%" e.g. "C:\Home Path\this script_yyyy-mm-dd_hh-mm-ss.log"
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
:ConvertTimeToSeconds TimeValue [/D]
:: Takes a given 24-hour time input like " 5:47:23.52" or "21-31-39" and converts it into seconds
:: 		/D 	Include decimal calculations. If this switch is omitted any decimal values passed will be dropped.
:: Output: %_TIME_SECONDS%
@ECHO OFF
SETLOCAL
SET "_INPUT_TIME=%~1"
SET "_SEC_SWITCH=%~2"
:: https://ss64.com/nt/syntax-substring.html
:: Extract Hours (first 2 digits)
SET "_TIME_HOURS=%_INPUT_TIME:~0,2%"
:: Bugfix: Check if first digit in hours is a zero (e.g. 09) or blank
:: Extract the first character out of _TIME_HOURS
SET "_TIME_HOURS_FIRST=%_TIME_HOURS:~0,1%"
IF "%_TIME_HOURS_FIRST%"==" " (
	REM Set _TIME_HOURS to the second character (instead of first 2 digits of string)
	SET "_TIME_HOURS=%_INPUT_TIME:~1,1%"
) ELSE (
	IF "%_TIME_HOURS_FIRST%"=="0" (
		REM Bugfix: Cannot use ' IF %_TIME_HOURS_FIRST% EQU 0 ' since if the first character is a space, it will still fail with "0 was unexpected at this time." Must do a string compare.
		REM Set _TIME_HOURS to the second character (instead of first 2 digits of string)
		SET "_TIME_HOURS=%_INPUT_TIME:~1,1%"
	)
)
::ECHO Hour = %_TIME_HOURS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Extract Minutes (4th and 5th character)
SET "_TIME_MINS=%_INPUT_TIME:~3,2%"
:: Bugfix: Check if first digit in minutes is a zero (e.g. 09)
:: Extract the first character out of _TIME_MINS
SET "_TIME_MINS_FIRST=%_TIME_MINS:~0,1%"
IF %_TIME_MINS_FIRST% EQU 0 (
	REM Set _TIME_MINS to the 5th character, rather than the 4th and 5th characters
	SET "_TIME_MINS=%_INPUT_TIME:~4,1%"
)
::ECHO Mins = %_TIME_MINS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Extract Seconds (7th and 8th characters)
SET "_TIME_SECS=%_INPUT_TIME:~6,2%"
:: Bugfix: Check if first digit in seconds is a zero (e.g. 09)
:: Extract the first character out of _TIME_SECS
SET "_TIME_SECS_FIRST=%_TIME_SECS:~0,1%"
IF %_TIME_SECS_FIRST% EQU 0 (
	REM Extract the 8th character
	SET "_TIME_SECS=%_INPUT_TIME:~7,1%"
)
::ECHO Secs = %_TIME_SECS%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Make hours into minutes (multiply by 60)
SET /A "_TIME_HOURS_MINS=%_TIME_HOURS%*60"
:: Add to minutes
SET /A "_TIME_MINS+=%_TIME_HOURS_MINS%"
:: Make minutes into seconds (multiply by 60)
SET /A "_TIME_MINS_SECS=%_TIME_MINS%*60"
:: Add to seconds
SET /A "_TIME_SECS+=%_TIME_MINS_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_SWITCH_LETTER=%_SEC_SWITCH:~1,1%"
IF /I "%_SWITCH_LETTER%"=="D" (
	REM Extract Seconds (everything after the 8th character)
	SET "_TIME_MILISECS=%_INPUT_TIME:~8%"
	REM Appends everything extracted (fractions of a second) to the end of our final seconds calculation.
	SET "_TIME_SECS=%_TIME_MINS_SECS%%_TIME_MILISECS%"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_TIME_SECONDS=%_TIME_SECS%"
EXIT /B
:-------------------------------------------------------------------------------
:ConvertSecondsToTime TimeValInSeconds
:: Takes a value given in seconds and converts it into several time formats
:: Outputs:
:: "%_TIME_FORMATTED%" (will always be exactly 8 characters long) e.g. " 9:31:39"
:: "%_TIME_SORTABLE%" (will always be exactly 8 characters long) e.g. "09-31-39"
:: "%_TIME_DURATION%" (will always be exactly 12 characters long) e.g. "  9h 31m 39s" or "109h  7m  9s"
@ECHO OFF
SETLOCAL
SET "_INPUT_SECS=%~1"
:: https://ss64.com/nt/set.html
:: Get minutes from seconds
SET /A "_TIME_MINS=%_INPUT_SECS%/60"
:: Keep the remainder as seconds
SET /A "_TIME_SECS=%_INPUT_SECS%%%60"
:: Get hours from minutes
SET /A "_TIME_HOURS=%_TIME_MINS%/60"
:: Keep the remainder as minutes
SET /A "_TIME_MINS%%=60"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like " 9:31:39" (FORMATTED)
IF %_TIME_HOURS% LSS 10 (SET "_FORM_HOURS= %_TIME_HOURS%") ELSE (SET "_FORM_HOURS=%_TIME_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_FORM_MINS=0%_TIME_MINS%") ELSE (SET "_FORM_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_FORM_SECS=0%_TIME_SECS%") ELSE (SET "_FORM_SECS=%_TIME_SECS%")
SET "_FORM_TIME=%_FORM_HOURS%:%_FORM_MINS%:%_FORM_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like "09-31-39" (SORTABLE)
IF %_TIME_HOURS% LSS 10 (SET "_SORT_HOURS=0%_TIME_HOURS%") ELSE (SET "_SORT_HOURS=%_TIME_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_SORT_MINS=0%_TIME_MINS%") ELSE (SET "_SORT_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_SORT_SECS=0%_TIME_SECS%") ELSE (SET "_SORT_SECS=%_TIME_SECS%")
SET "_SORT_TIME=%_SORT_HOURS%-%_SORT_MINS%-%_SORT_SECS%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Format time like "  9h 31m 39s" (DURATION)
IF %_TIME_HOURS% LSS 100 (SET "_DUR_HOURS= %_TIME_HOURS%") ELSE (SET "_DUR_HOURS=%_TIME_HOURS%")
IF %_TIME_HOURS% LSS 10 (SET "_DUR_HOURS= %_DUR_HOURS%") ELSE (SET "_DUR_HOURS=%_DUR_HOURS%")
IF %_TIME_MINS% LSS 10 (SET "_DUR_MINS= %_TIME_MINS%") ELSE (SET "_DUR_MINS=%_TIME_MINS%")
IF %_TIME_SECS% LSS 10 (SET "_DUR_SECS= %_TIME_SECS%") ELSE (SET "_DUR_SECS=%_TIME_SECS%")
SET "_DUR_TIME=%_DUR_HOURS%h %_DUR_MINS%m %_DUR_SECS%s"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_TIME_FORMATTED=%_FORM_TIME%" & SET "_TIME_SORTABLE=%_SORT_TIME%" & SET "_TIME_DURATION=%_DUR_TIME%"
EXIT /B
:-------------------------------------------------------------------------------
:InitLogOriginal
:: Initiate Log with a header in a subdirectory called "Logs"
:: Dependencies are :GetWindowsVersion
@ECHO OFF
SETLOCAL
SET "_DATE=%DATE%"
::ECHO Current date = %_DATE%
:: https://ss64.com/nt/syntax-substring.html
:: Skip 4 characters and then extract everything else
SET "_DATE_SML=%_DATE:~4%"
:: https://ss64.com/nt/syntax-replace.html
:: Replace the character string '/' with '-'
SET "_DATE_STR=%_DATE_SML:/=-%"
::ECHO Date string = %_DATE_STR%
:: https://ss64.com/nt/syntax-args.html
:: %~f1 Expand %1 to a Fully qualified path name - C:\utils\MyFile.txt
::SET "_HOME_PATH=%~dpn0"
::SET "_HOME_PATH=%~dp0Logs\%~n0"
::SET "_HOME_PATH=D:\%~n0"
SET "_HOME_PATH=%~dp0"
::ECHO Current path = %_HOME_PATH%
SET "_LOG_PATH=%_HOME_PATH%Logs"
::ECHO Log path = %_LOG_PATH%
SET "_LOG_FILE=%_LOG_PATH%\%~n0_%_DATE_STR%.log"
::ECHO Log file = %_LOG_FILE%
IF NOT EXIST "%_LOG_PATH%" MKDIR "%_LOG_PATH%"
ECHO:>>"%_LOG_FILE%"
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ->>"%_LOG_FILE%"
ECHO.>>"%_LOG_FILE%"
ECHO Computer name: %COMPUTERNAME%>>"%_LOG_FILE%"
ECHO User name: %USERNAME%>>"%_LOG_FILE%"
CALL :GetWindowsVersion>NUL
ECHO Windows version: %_WindowsEasyName% ^(v%_WindowsVersion%^)>>"%_LOG_FILE%"
ECHO Script name: %~nx0>>"%_LOG_FILE%"
ECHO Date: %_DATE%>>"%_LOG_FILE%"
ECHO Time: %TIME%>>"%_LOG_FILE%"
ECHO.>>"%_LOG_FILE%"
ENDLOCAL & SET "_LOGFILE=%_LOG_FILE%" & SET "_LOGPATH=%_LOG_PATH%"
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:InitLog [LogPathAndFilename]
:: Initiate Log with a detailed Header at the Log Path provided (Path + Name + Extension) 
:: e.g. "C:\Home Path\this script_2018-03-07.log"
:: If no log path is provided, will default to a subdirectory called "Logs"
:: Dependencies are :GetDate and :GetWindowsVersion
@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET "_PASSED_PATH=%~1"
::ECHO 1 = "%_PASSED_PATH%"
::Also works: IF [%1]==[] (
IF [!_PASSED_PATH!]==[] (
	REM https://ss64.com/nt/syntax-args.html
	SET "_HOME_PATH=%~dp0"
	REM ECHO Current path = !_HOME_PATH!
	SET "_LOG_PATH=!_HOME_PATH!Logs"
	REM ECHO Log path = !_LOG_PATH!
	CALL :GetDate
	SET "_DEFAULT_PATH=!_LOG_PATH!\%~n0_%_SORTABLE_DATE%.log"
	SET "_LOG_FILE=!_DEFAULT_PATH!"
) ELSE (
	SET "_LOG_FILE=%_PASSED_PATH%"
	FOR /F "tokens=*" %%G IN ("!_LOG_FILE!") DO (SET "_LOG_PATH=%%~dpG")
)
IF NOT EXIST "%_LOG_PATH%" MKDIR "%_LOG_PATH%"
::ECHO Log file = %_LOG_FILE%
::ECHO Log path = %_LOG_PATH%
ECHO:>>"%_LOG_FILE%"
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ->>"%_LOG_FILE%"
ECHO.>>"%_LOG_FILE%"
ECHO Computer name: %COMPUTERNAME%>>"%_LOG_FILE%"
ECHO User name: %USERNAME%>>"%_LOG_FILE%"
CALL :GetWindowsVersion>NUL
ECHO Windows version: %_WindowsEasyName% ^(v%_WindowsVersion%^)>>"%_LOG_FILE%"
ECHO Script name: %~nx0>>"%_LOG_FILE%"
ECHO Date: %DATE%>>"%_LOG_FILE%"
ECHO Time: %_FORMATTED_TIME%>>"%_LOG_FILE%"
ECHO.>>"%_LOG_FILE%"
ENDLOCAL & SET "_LOGFILE=%_LOG_FILE%" & SET "_LOGPATH=%_LOG_PATH%"
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:SplashLogoKdiff
::CALL :SplashLogoKdiff
:: For source see "kdiff-ascii-text.bat"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
::SETLOCAL
::patorjk.com
::ECHO Font Name: Big Money-nw
::ECHO -------------------------------------------------------------------------------
::ECHO $$\             $$\ $$\  $$$$$$\   $$$$$$\    
::ECHO $$ |            $$ |\__|$$  __$$\ $$  __$$\   
::ECHO $$ |  $$\  $$$$$$$ |$$\ $$ /  \__|$$ /  \__|  
::ECHO $$ | $$  |$$  __$$ |$$ |$$$$\     $$$$\       
::ECHO $$$$$$  / $$ /  $$ |$$ |$$  _|    $$  _|      
::ECHO $$  _$$<  $$ |  $$ |$$ |$$ |      $$ |        
::ECHO $$ | \$$\ \$$$$$$$ |$$ |$$ |      $$ |        
::ECHO \__|  \__| \_______|\__|\__|      \__|        
::ECHO -------------------------------------------------------------------------------
:: Replace:
:: 		|	with	^|
:: 		<	with	^<
::ECHO -------------------------------------------------------------------------------
ECHO $$\             $$\ $$\  $$$$$$\   $$$$$$\    
ECHO $$ ^|            $$ ^|\__^|$$  __$$\ $$  __$$\   
ECHO $$ ^|  $$\  $$$$$$$ ^|$$\ $$ /  \__^|$$ /  \__^|  
ECHO $$ ^| $$  ^|$$  __$$ ^|$$ ^|$$$$\     $$$$\       
ECHO $$$$$$  / $$ /  $$ ^|$$ ^|$$  _^|    $$  _^|      
ECHO $$  _$$^<  $$ ^|  $$ ^|$$ ^|$$ ^|      $$ ^|        
ECHO $$ ^| \$$\ \$$$$$$$ ^|$$ ^|$$ ^|      $$ ^|        
ECHO \__^|  \__^| \_______^|\__^|\__^|      \__^|        
::ECHO -------------------------------------------------------------------------------
::PAUSE
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ENDLOCAL
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:SplashLogoMerge
::CALL :SplashLogoMerge
:: For source see "merge-ascii-test.bat" and "merge-ascii-test.txt"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
::SETLOCAL
::patorjk.com
::Font Name: Epic
:: Original artwork:
::ECHO:
::ECHO  (                             
::ECHO   \  _,--._,-.__,         )    
::ECHO   / (,  ,       ,`-._    /     
::ECHO  (  ,^--^-. ;--^--/ (    \     
::ECHO   :'      `/       \ )   /     
::ECHO   (  o    (   o    |(  \'        _______  _______  _______  _______  _______   
::ECHO    \  ,----\       /(,-.)       (       )(  ____ \(  ____ )(  ____ \(  ____ \  
::ECHO   ,'`-\___  `.___,'  ,. )       | () () || (    \/| (    )|| (    \/| (    \/  
::ECHO ,'                   __/        | || || || (__    | (____)|| |      | (__      
::ECHO `-.______________   |,---,      | |(_)| ||  __)   |     __)| | ____ |  __)     
::ECHO       `-^;-^--^-'\  |   '----,  | |   | || (      | (\ (   | | \_  )| (        
::ECHO         ( '------'  .',-.___/   | )   ( || (____/\| ) \ \__| (___) || (____/\  
::ECHO          ;._____,--' / \        |/     \|(_______/|/   \__/(_______)(_______/  
::ECHO  -hrr-  (           /   \      
::ECHO         (`-        /     \     
::ECHO          \       ,'       \    
::ECHO         / )  _,-'          \   
::ECHO        / (,-'       \       \  
::ECHO:
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ECHO ###############################################################################
::ECHO # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
::ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
::ECHO ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
::ECHO . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO  (                                                                             
ECHO   \  _,--._,-.__,         )    
ECHO   / (,  ,       ,`-._    /     
ECHO  (  ,^^--^^-. ;--^^--/ (    \     
ECHO   :'      `/       \ )   /     
ECHO   (  o    (   o    ^|(  \'        _______  _______  _______  _______  _______   
ECHO    \  ,----\       /(,-.)       (       )(  ____ \(  ____ )(  ____ \(  ____ \  
ECHO   ,'`-\___  `.___,'  ,. )       ^| () () ^|^| (    \/^| (    )^|^| (    \/^| (    \/  
ECHO ,'                   __/        ^| ^|^| ^|^| ^|^| (__    ^| (____)^|^| ^|      ^| (__      
ECHO `-.______________   ^|,---,      ^| ^|(_)^| ^|^|  __)   ^|     __)^| ^| ____ ^|  __)     
ECHO       `-^^;-^^--^^-'\  ^|   '----,  ^| ^|   ^| ^|^| (      ^| (\ (   ^| ^| \_  )^| (        
ECHO         ( '------'  .',-.___/   ^| )   ( ^|^| (____/\^| ) \ \__^| (___) ^|^| (____/\  
ECHO          ;._____,--' / \        ^|/     \^|(_______/^|/   \__/(_______)(_______/  
ECHO         (           /   \      
ECHO         (`-        /     \     
ECHO          \       ,'       \    
ECHO         / )  _,-'          \   
ECHO        / (,-'       \       \  
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ENDLOCAL
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:SplashLogoMergeComplete
::CALL :SplashLogoMergeComplete
:: For source see "merge-ascii-test.bat" and "merge-ascii-test.txt"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
::SETLOCAL
::patorjk.com
::Font Name: Crazy
::ECHO      __  __   ___         __.....__                           __.....__       #
::ECHO     |  |/  `.'   `.   .-''         '.             .--./)  .-''         '.     #
::ECHO     |   .-.  .-.   ' /     .-''"'-.  `. .-,.--.  /.''\\  /     .-''"'-.  `.   #
::ECHO     |  |  |  |  |  |/     /________\   \|  .-. || |  | |/     /________\   \  #
::ECHO     |  |  |  |  |  ||                  || |  | | \`-' / |                  |  #
::ECHO     |  |  |  |  |  |\    .-------------'| |  | | /("'`  \    .-------------'  #
::ECHO     |  |  |  |  |  | \    '-.____...---.| |  '-  \ '---. \    '-.____...---.  #
::ECHO     |__|  |__|  |__|  `.             .' | |       /'""'.\ `.             .'   #
::ECHO                         `''-...... -'   | |      ||     ||  `''-...... -'     #
::ECHO                                         |_|      \'. __//                     #
::ECHO                                                   `'---'                      #
:: Original artwork:
::ECHO         *                                      ,                              #
::ECHO       (  `                                    (                          )    #
::ECHO       )\))(     (   (    (  (     (            \                        /     #
::ECHO      ((_)()\   ))\  )(   )\))(   ))\          ,' ,__,___,__,-._         )     #
::ECHO      (_()((_) /((_)(()\ ((_))\  /((_)         )-' ,    ,  , , (        /      #
::ECHO      |  \/  |(_))   ((_) (()(_)(_))           ;'"-^-.,-''"""\' \       )      #
::ECHO      | |\/| |/ -_) | '_|/ _` | / -_)         (      (        ) /  __  /       #
::ECHO      |_|  |_|\___| |_|  \__, | \___|          \o,----.  o  _,'( ,.^. \        #
::ECHO                         |___/                 ,'`.__  `---'    `\ \ \ \_      #
::ECHO                                        ,.,. ,'                   \    ' )     #
::ECHO                                        \ \ \\__  ,------------.  /     /      #
::ECHO                                       ( \ \ \( `---.-`-^--,-,--\:     :       #
::ECHO                                        \       (   (""""""`----'|     : -hrr- #
::ECHO                                         \   `.  \   `.          |      \      #
::ECHO                                          \   ;  ;     )      __ _\      \     #
::ECHO                                          /     /    ,-.,-.'"Y  Y  \      `.   #
::ECHO                                         /     :    ,`-'`-'`-'`-'`-'\       `. #
::ECHO                                        /      ;  ,'  /              \        `#
::ECHO                                       /      / ,'   /                \        #
::Font Name: Big
::ECHO              _____ ____  __  __ _____  _      ______ _______ ______           #
::ECHO             / ____/ __ \|  \/  |  __ \| |    |  ____|__   __|  ____|          #
::ECHO            | |   | |  | | \  / | |__) | |    | |__     | |  | |__             #
::ECHO            | |   | |  | | |\/| |  ___/| |    |  __|    | |  |  __|            #
::ECHO            | |___| |__| | |  | | |    | |____| |____   | |  | |____           #
::ECHO             \_____\____/|_|  |_|_|    |______|______|  |_|  |______|          #

::Font Name: Fire Font-k
::ECHO         *                             #
::ECHO       (  `                            #
::ECHO       )\))(     (   (    (  (     (   #
::ECHO      ((_)()\   ))\  )(   )\))(   ))\  #
::ECHO      (_()((_) /((_)(()\ ((_))\  /((_) #
::ECHO      |  \/  |(_))   ((_) (()(_)(_))   #
::ECHO      | |\/| |/ -_) | '_|/ _` | / -_)  #
::ECHO      |_|  |_|\___| |_|  \__, | \___|  #
::ECHO                         |___/         #
::ECHO:
::ECHO         *                             #
::ECHO       (  `                            #
::ECHO       )\))(     (   (    (  (     (   #
::ECHO      ((_)()\   ))\  )(   )\))(   ))\  #
::ECHO      (_()((_) /((_)(()\ ((_))\  /((_) #
::ECHO      ^|  \/  ^|(_))   ((_) (()(_)(_))   #
::ECHO      ^| ^|\/^| ^|/ -_) ^| '_^|/ _` ^| / -_)  #
::ECHO      ^|_^|  ^|_^|\___^| ^|_^|  \__, ^| \___^|  #
::ECHO                         ^|___/         #
::ECHO:
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO      __  __   ___         __.....__                           __.....__       #
ECHO     ^|  ^|/  `.'   `.   .-''         '.             .--./)  .-''         '.     #
ECHO     ^|   .-.  .-.   ' /     .-''"'-.  `. .-,.--.  /.''\\  /     .-''"'-.  `.   #
ECHO     ^|  ^|  ^|  ^|  ^|  ^|/     /________\   \^|  .-. ^|^| ^|  ^| ^|/     /________\   \  #
ECHO     ^|  ^|  ^|  ^|  ^|  ^|^|                  ^|^| ^|  ^| ^| \`-' / ^|                  ^|  #
ECHO     ^|  ^|  ^|  ^|  ^|  ^|\    .-------------'^| ^|  ^| ^| /("'`  \    .-------------'  #
ECHO     ^|  ^|  ^|  ^|  ^|  ^| \    '-.____...---.^| ^|  '-  \ '---. \    '-.____...---.  #
ECHO     ^|__^|  ^|__^|  ^|__^|  `.             .' ^| ^|       /'""'.\ `.             .'   #
ECHO                         `''-...... -'   ^| ^|      ^|^|     ^|^|  `''-...... -'     #
ECHO                                         ^|_^|      \'. __//                     #
ECHO                                                   `'---'                      #
ECHO         *                                      ,                              #
ECHO       (  `                                    (                          )    #
ECHO       )\))(     (   (    (  (     (            \                        /     #
ECHO      ((_)()\   ))\  )(   )\))(   ))\          ,' ,__,___,__,-._         )     #
ECHO      (_()((_) /((_)(()\ ((_))\  /((_)         )-' ,    ,  , , (        /      #
::ECHO      ^|  \/  ^|(_))   ((_) (()(_)(_))           ;'"-^^-.,-''"""\' \       )      #
ECHO      ^|  \/  ^|(_))   ((_) (()(_)(_))           ;'"-^-.,-''"""\' \       )      #
ECHO      ^| ^|\/^| ^|/ -_) ^| '_^|/ _` ^| / -_)         (      (        ) /  __  /       #
ECHO      ^|_^|  ^|_^|\___^| ^|_^|  \__, ^| \___^|          \o,----.  o  _,'( ,.^^. \        #
ECHO                         ^|___/                 ,'`.__  `---'    `\ \ \ \_      #
ECHO                                        ,.,. ,'                   \    ' )     #
ECHO                                        \ \ \\__  ,------------.  /     /      #
ECHO                                       ( \ \ \( `---.-`-^^--,-,--\:     :       #
ECHO                                        \       (   (""""""`----'^|     : -hrr- #
ECHO                                         \   `.  \   `.          ^|      \      #
ECHO                                          \   ;  ;     )      __ _\      \     #
ECHO                                          /     /    ,-.,-.'"Y  Y  \      `.   #
ECHO                                         /     :    ,`-'`-'`-'`-'`-'\       `. #
ECHO                                        /      ;  ,'  /              \        `#
ECHO                                       /      / ,'   /                \        #
ECHO              _____ ____  __  __ _____  _      ______ _______ ______           #
ECHO             / ____/ __ \^|  \/  ^|  __ \^| ^|    ^|  ____^|__   __^|  ____^|          #
ECHO            ^| ^|   ^| ^|  ^| ^| \  / ^| ^|__) ^| ^|    ^| ^|__     ^| ^|  ^| ^|__             #
ECHO            ^| ^|   ^| ^|  ^| ^| ^|\/^| ^|  ___/^| ^|    ^|  __^|    ^| ^|  ^|  __^|            #
ECHO            ^| ^|___^| ^|__^| ^| ^|  ^| ^| ^|    ^| ^|____^| ^|____   ^| ^|  ^| ^|____           #
ECHO             \_____\____/^|_^|  ^|_^|_^|    ^|______^|______^|  ^|_^|  ^|______^|          #
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ECHO      __  __   ___         __.....__                           __.....__       #
::ECHO     |  |/  `.'   `.   .-''         '.             .--./)  .-''         '.     #
::ECHO     |   .-.  .-.   ' /     .-''"'-.  `. .-,.--.  /.''\\  /     .-''"'-.  `.   #
::ECHO     |  |  |  |  |  |/     /________\   \|  .-. || |  | |/     /________\   \  #
::ECHO     |  |  |  |  |  ||                  || |  | | \`-' / |                  |  #
::ECHO     |  |  |  |  |  |\    .-------------'| |  | | /("'`  \    .-------------'  #
::ECHO     |  |  |  |  |  | \    '-.____...---.| |  '-  \ '---. \    '-.____...---.  #
::ECHO     |__|  |__|  |__|  `.             .' | |       /'""'.\ `.             .'   #
::ECHO                         `''-...... -'   | |      ||     ||  `''-...... -'     #
::ECHO         *                               |_|    , \'. __//                     #
::ECHO       (  `                                    (   `'---'                 )    #
::ECHO       )\))(     (   (    (  (     (            \                        /     #
::ECHO      ((_)()\   ))\  )(   )\))(   ))\          ,' ,__,___,__,-._         )     #
::ECHO      (_()((_) /((_)(()\ ((_))\  /((_)         )-' ,    ,  , , (        /      #
::ECHO      |  \/  |(_))   ((_) (()(_)(_))           ;'"-^-.,-''"""\' \       )      #
::ECHO      | |\/| |/ -_) | '_|/ _` | / -_)         (      (        ) /  __  /       #
::ECHO      |_|  |_|\___| |_|  \__, | \___|          \o,----.  o  _,'( ,.^. \        #
::ECHO                         |___/                 ,'`.__  `---'    `\ \ \ \_      #
::ECHO                                        ,.,. ,'                   \    ' )     #
::ECHO                                        \ \ \\__  ,------------.  /     /      #
::ECHO                                       ( \ \ \( `---.-`-^--,-,--\:     :       #
::ECHO                                        \       (   (""""""`----'|     : -hrr- #
::ECHO                                         \   `.  \   `.          |      \      #
::ECHO                                          \   ;  ;     )      __ _\      \     #
::ECHO                                          /     /    ,-.,-.'"Y  Y  \      `.   #
::ECHO                                         /     :    ,`-'`-'`-'`-'`-'\       `. #
::ECHO                                        /      ;  ,'  /              \        `#
::ECHO              _____ ____  __  __ _____ /_     /__'___/_______ ______  \        #
::ECHO             / ____/ __ \|  \/  |  __ \| |    |  ____|__   __|  ____|          #
::ECHO            | |   | |  | | \  / | |__) | |    | |__     | |  | |__             #
::ECHO            | |   | |  | | |\/| |  ___/| |    |  __|    | |  |  __|            #
::ECHO            | |___| |__| | |  | | |    | |____| |____   | |  | |____           #
::ECHO             \_____\____/|_|  |_|_|    |______|______|  |_|  |______|          #
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ECHO      __  __   ___         __.....__                           __.....__       #
::ECHO     ^|  ^|/  `.'   `.   .-''         '.             .--./)  .-''         '.     #
::ECHO     ^|   .-.  .-.   ' /     .-''"'-.  `. .-,.--.  /.''\\  /     .-''"'-.  `.   #
::ECHO     ^|  ^|  ^|  ^|  ^|  ^|/     /________\   \^|  .-. ^|^| ^|  ^| ^|/     /________\   \  #
::ECHO     ^|  ^|  ^|  ^|  ^|  ^|^|                  ^|^| ^|  ^| ^| \`-' / ^|                  ^|  #
::ECHO     ^|  ^|  ^|  ^|  ^|  ^|\    .-------------'^| ^|  ^| ^| /("'`  \    .-------------'  #
::ECHO     ^|  ^|  ^|  ^|  ^|  ^| \    '-.____...---.^| ^|  '-  \ '---. \    '-.____...---.  #
::ECHO     ^|__^|  ^|__^|  ^|__^|  `.             .' ^| ^|       /'""'.\ `.             .'   #
::ECHO                         `''-...... -'   ^| ^|      ^|^|     ^|^|  `''-...... -'     #
::ECHO         *                               ^|_^|    , \'. __//                     #
::ECHO       (  `                                    (   `'---'                 )    #
::ECHO       )\))(     (   (    (  (     (            \                        /     #
::ECHO      ((_)()\   ))\  )(   )\))(   ))\          ,' ,__,___,__,-._         )     #
::ECHO      (_()((_) /((_)(()\ ((_))\  /((_)         )-' ,    ,  , , (        /      #
::::ECHO      ^|  \/  ^|(_))   ((_) (()(_)(_))           ;'"-^^-.,-''"""\' \       )      #
::ECHO      ^|  \/  ^|(_))   ((_) (()(_)(_))           ;'"-^-.,-''"""\' \       )      #
::ECHO      ^| ^|\/^| ^|/ -_) ^| '_^|/ _` ^| / -_)         (      (        ) /  __  /       #
::ECHO      ^|_^|  ^|_^|\___^| ^|_^|  \__, ^| \___^|          \o,----.  o  _,'( ,.^^. \        #
::ECHO                         ^|___/                 ,'`.__  `---'    `\ \ \ \_      #
::ECHO                                        ,.,. ,'                   \    ' )     #
::ECHO                                        \ \ \\__  ,------------.  /     /      #
::ECHO                                       ( \ \ \( `---.-`-^^--,-,--\:     :       #
::ECHO                                        \       (   (""""""`----'^|     : -hrr- #
::ECHO                                         \   `.  \   `.          ^|      \      #
::ECHO                                          \   ;  ;     )      __ _\      \     #
::ECHO                                          /     /    ,-.,-.'"Y  Y  \      `.   #
::ECHO                                         /     :    ,`-'`-'`-'`-'`-'\       `. #
::ECHO                                        /      ;  ,'  /              \        `#
::ECHO              _____ ____  __  __ _____ /_     /__'___/_______ ______  \        #
::ECHO             / ____/ __ \^|  \/  ^|  __ \^| ^|    ^|  ____^|__   __^|  ____^|          #
::ECHO            ^| ^|   ^| ^|  ^| ^| \  / ^| ^|__) ^| ^|    ^| ^|__     ^| ^|  ^| ^|__             #
::ECHO            ^| ^|   ^| ^|  ^| ^| ^|\/^| ^|  ___/^| ^|    ^|  __^|    ^| ^|  ^|  __^|            #
::ECHO            ^| ^|___^| ^|__^| ^| ^|  ^| ^| ^|    ^| ^|____^| ^|____   ^| ^|  ^| ^|____           #
::ECHO             \_____\____/^|_^|  ^|_^|_^|    ^|______^|______^|  ^|_^|  ^|______^|          #
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ENDLOCAL
EXIT /B
::GOTO :EOF
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions

:Footer
:END
ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.
