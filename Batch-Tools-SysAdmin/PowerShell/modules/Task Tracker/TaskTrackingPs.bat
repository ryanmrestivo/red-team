@ECHO OFF
::SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Parameters
:: 5. :Main
:: 6. :Footer
:: 7. :DefineFunctions

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
:: <-- Remove this block to always RunAs Administrator -->
ECHO:
ECHO CHOICE Loading...
ECHO:
:: https://ss64.com/nt/choice.html
CHOICE /M "Run as Administrator?"
IF ERRORLEVEL 2 GOTO START & REM No.
IF ERRORLEVEL 1 REM Yes.
:: <-- Remove this block to always RunAs Administrator -->
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

:: To run from PowerShell command line:
:: https://ss64.com/ps/syntax-run.html
:: https://ss64.com/ps/call.html
:: & "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Sort-FilesByDate.ps1"
:: & "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Sort-FilesByDate.ps1" -Verbose -Debug
:: & "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template.ps1" -Verbose -Debug -LaunchedInCmd
:: https://ss64.com/ps/source.html
:: . "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template.ps1"
:: . "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template.ps1" -Verbose -Debug
:: . "C:\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template.ps1" -Verbose -Debug -LaunchedInCmd

:: Execution Policy:
:: $oldExecutionPolicy = Get-ExecutionPolicy
:: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
:: Set-ExecutionPolicy -ExecutionPolicy Bypass
:: Set-ExecutionPolicy $oldExecutionPolicy

:: End Header

REM -------------------------------------------------------------------------------

:Parameters

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = ExecutionPolicy

:: Alternate ExecutionPolicy = Bypass
::https://www.howtogeek.com/204088/how-to-use-a-batch-file-to-make-powershell-scripts-easier-to-run/
SET "_batExecutionPolicy=Bypass"
SET "_batExecutionPolicy=RemoteSigned"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = Example Help Command

SET "_EXAMPLE_HELP_COMMAND=Get-ChildItem"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param3 = PowerShell Script Parameters

SET "_POSH_PARAMS="

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 2: Example PowerShell help command
:: Phase 3: PowerShell script help command
:: Phase 4: Main Menu
:: Phase 5: Run PowerShell script as Administrator
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate Parameters
::===============================================================================

:: Check if out target file exists
IF NOT EXIST "%~dpn0.ps1" (
	ECHO:
	ECHO -------------------------------------------------------------------------------
	ECHO WARNING:
	ECHO -------------------------------------------------------------------------------
	ECHO:
	ECHO "%~dpn0.ps1" not found.
	ECHO:
	PAUSE
	EXIT
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 2: Example PowerShell help command
::===============================================================================

:ExampleHelp
:: Skip Example Help lookup
ECHO Skipping %_EXAMPLE_HELP_COMMAND% example help command & GOTO ScriptHelp & REM Comment out this line to display help before loading script

ECHO -------------------------------------------------------------------------------
ECHO:
ECHO Example help:
ECHO:
ECHO Get-Help %_EXAMPLE_HELP_COMMAND%
ECHO:
:: https://ss64.com/nt/syntax-args.html
PowerShell.exe -NoProfile -Command Get-Help %_EXAMPLE_HELP_COMMAND%
ECHO:
ECHO -------------------------------------------------------------------------------

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 3: PowerShell script help command
::===============================================================================

:ScriptHelp
:: Skip Help lookup
ECHO Skipping %~n0.ps1 help command & GOTO MainMenu & REM Comment out this line to display help before loading script

ECHO -------------------------------------------------------------------------------
ECHO:
ECHO Full script help:
ECHO:
ECHO %~dpn0.ps1
ECHO Get-Help .\%~n0.ps1
ECHO:
:: https://ss64.com/nt/syntax-args.html
::PowerShell.exe -NoProfile -Command Get-Help %~dpn0.ps1 -Full
PowerShell.exe -NoProfile -Command Get-Help .\%~n0.ps1 -Full
ECHO:
ECHO -------------------------------------------------------------------------------

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM ===============================================================================

::===============================================================================
:: Phase 4: Main Menu
::===============================================================================

::GOTO AdminVerboseRun
::GOTO AdminRunScript

:MainMenu
ECHO:
ECHO %~n0.ps1
ECHO:
ECHO Detecting Windows OS version compatibility . . . 
ECHO:
CALL :GetWindowsVersion
ECHO:
:: https://ss64.com/nt/choice.html
ECHO CHOICE Loading...
::CHOICE /C LDWE /N /M "|  L - Log Times  |  D - Stats by Day  |  W - by Week  |  -----  |  E - Exit  |"
CHOICE /C RVDG /N /M "|  R - Run Script  |  V - Verbose  |  D - Debug  |  G - Debug & Verbose  |    |"
IF ERRORLEVEL 4 GOTO DebugAndVerbose
IF ERRORLEVEL 3 GOTO DebugScript
IF ERRORLEVEL 2 GOTO VerboseRun
IF ERRORLEVEL 1 GOTO RunScript
ECHO:
ECHO ERROR: Invalid choice / Choice not recognized.
ECHO:
GOTO MainMenu

:: Alternate ExecutionPolicy = Bypass
::https://www.howtogeek.com/204088/how-to-use-a-batch-file-to-make-powershell-scripts-easier-to-run/

:: The dot sourcing feature lets you run a script in the current scope instead of in the script scope.
:: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-6&viewFallbackFrom=powershell-Microsoft.PowerShell.Core

:: Call operator (&) allows you to execute a command, script or function. 
:: https://ss64.com/ps/call.html


:RunScript
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command . '%~dpn0.ps1' -LaunchedInCmd
IF %_WindowsVersion% EQU 10 (
	REM Windows 10 has PowerShell width CMD.exe windows.
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1"
) ELSE (
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -LaunchedInCmd
)
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1'"
GOTO End

:VerboseRun
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command . '%~dpn0.ps1' -LaunchedInCmd -Verbose
IF %_WindowsVersion% EQU 10 (
	REM Windows 10 has PowerShell width CMD.exe windows.
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -Verbose
) ELSE (
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -LaunchedInCmd -Verbose
)
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1' -LaunchedInCmd -Verbose"
GOTO End

:DebugScript
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command . '%~dpn0.ps1' -LaunchedInCmd -Debug
IF %_WindowsVersion% EQU 10 (
	REM Windows 10 has PowerShell width CMD.exe windows.
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -Debug
) ELSE (
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -LaunchedInCmd -Debug
)
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command & '%~dpn0.ps1' -LaunchedInCmd -Debug
GOTO End

:DebugAndVerbose 
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command . '%~dpn0.ps1' -LaunchedInCmd -Verbose -Debug
IF %_WindowsVersion% EQU 10 (
	REM Windows 10 has PowerShell width CMD.exe windows.
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -Verbose -Debug
) ELSE (
	PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dpn0.ps1" -LaunchedInCmd -Verbose -Debug
)
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command & '%~dpn0.ps1' -LaunchedInCmd -Verbose -Debug
GOTO End

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 5: Run PowerShell script as Administrator
::===============================================================================

:AdminRunScript
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"
GOTO End

:AdminVerboseRun
::PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1"" -Verbose' -Verb RunAs}"
PowerShell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """"%~dpn0.ps1"""" -Verbose' -Verb RunAs}"
GOTO End


::http://blog.danskingdom.com/allow-others-to-run-your-powershell-scripts-from-a-batch-file-they-will-love-you-for-it/

::Here is how to pass in ordered parameters:

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%' 'First Param Value' 'Second Param Value'";

::And here is how to pass in named parameters:

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%' -Param1Name 'Param 1 Value' -Param2Name 'Param 2 Value'"

::And if you are running the admin version of the script, here is how to pass in ordered parameters:

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """"%PowerShellScriptPath%"""" """"First Param Value"""" """"Second Param Value"""" ' -Verb RunAs}"

::And here is how to pass in named parameters:

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File """"%PowerShellScriptPath%"""" -Param1Name """"Param 1 Value"""" -Param2Name """"Param 2 value"""" ' -Verb RunAs}";

::And yes, the PowerShell script name and parameters need to be wrapped in 4 double quotes in order to properly handle paths/values with spaces.




ECHO:
ECHO -------------------------------------------------------------------------------

:: End Main

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:Footer
:END
::ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.

:: End Footer

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin DefineFunctions block.

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :GetWindowsVersion

GOTO SkipFunctions
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
:: End functions
:SkipFunctions
