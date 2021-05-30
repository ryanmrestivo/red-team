@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :RunAsAdministrator
:: 2. :Header
:: 3. :Parameters
:: 4. :ExternalFunctions
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
::PAUSE
::CLS
:SkipHeader

:: End Header

REM -------------------------------------------------------------------------------

:Parameters

:: Input from 

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = Send File, or Receive File?

SET "_SEND_OR_RECEIVE=SEND"
SET "_SEND_OR_RECEIVE=RECEIVE"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = Local file path

::SET "_LOCAL_FILE=%UserProfile%\Documents\GitHub\Python-DynDNS-NameSilo\"
::SET "_LOCAL_FILE=%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS"
SET "_LOCAL_FILE=%UserProfile%\Nextcloud\Documents\Raspberry Pi\Pi-Hole DNS server\DynDNS"
::SET "_LOCAL_FILE=%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS\test-logcleanup.sh
::SET "_LOCAL_FILE=%UserProfile%\Documents\KeePass\"
::SET "_LOCAL_FILE=%UserProfile%\Documents\KeePass\Backup\"
::SET "_LOCAL_FILE=%UserProfile%\Documents\KeePass\PersonalVault.kdbx"
::SET "_LOCAL_FILE=%UserProfile%\Documents\Docker\containers\Home Assistant\docker-compose.yaml"
::SET "_LOCAL_FILE=%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\SSL-TLS encryption\certificate_backup\"
::SET "_LOCAL_FILE=%UserProfile%\Nextcloud\Documents\Docker\docker compose\projects\pipsqueak-plus\etc\letsencrypt\"
::SET "_LOCAL_FILE=%UserProfile%\Nextcloud\Documents\Docker\docker compose\projects\pipsqueak-plus\~\"
::SET "_LOCAL_FILE=%UserProfile%\Nextcloud\Documents\Docker\docker compose\projects\pipsqueak-plus\home\docker-compose.yaml"
::SET "_LOCAL_FILE=%UserProfile%\Documents\Wireshark"
SET "_LOCAL_FILE=%UserProfile%\Documents\+MyDocuments\DynDNS"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param3 = Remote file path

SET "_REMOTE_FILE=/home/pi/DynDNS/*.log"
::SET "_REMOTE_FILE=/home/pi/DynDNS/test-logcleanup.sh"
::SET "_REMOTE_FILE=/home/pi/pishare/*"
::SET "_REMOTE_FILE=/home/pi/pishare/"
::SET "_REMOTE_FILE=/home/g/docker/home-ass/"
::SET "_REMOTE_FILE=/home/g/docker/"
::SET "_REMOTE_FILE=/home/g/*"
::SET "_REMOTE_FILE=/home/getmo/packetcap/2019-10-05dump_4.pcap"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param4 = Remote host address, IP or DNS

::GOTO SkipParam4 & REM Un-comment this line to skip Param4 = _REMOTE_HOST

::SET "_REMOTE_HOST="
SET "_REMOTE_HOST=192.168.0.200"
::SET "_REMOTE_HOST=my.pi"
::SET "_REMOTE_HOST=192.168.0.201"
::SET "_REMOTE_HOST=rotteneggs.local"
::SET "_REMOTE_HOST=192.168.0.1"

:SkipParam4

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param5 = Remote host username to login with

::GOTO SkipParam5 & REM Un-comment this line to skip Param5 = _REMOTE_HOST_USERNAME

SET "_REMOTE_HOST_USERNAME="
SET "_REMOTE_HOST_USERNAME=pi"
::SET "_REMOTE_HOST_USERNAME=getmo"
::SET "_REMOTE_HOST_USERNAME=root"
::SET "_REMOTE_HOST_USERNAME=g"

:SkipParam5

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param6 = Password file location, if you already have one:

SET "_PW_FILE="
	
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param7 = Delete temporary password storage file?

:: Set _DONT_DELETE_PW_FILE to PRESERVE to keep it around for next run. Otherwise, it will be deleted at the end of script. 
:: If you set _DONT_DELETE_PW_FILE to anything else the password storage file will always be deleted.

SET "_DONT_DELETE_PW_FILE="
::SET "_DONT_DELETE_PW_FILE=PRESERVE"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param8 = Port to connect to:

SET "_REMOTE_HOST_PORT="
SET "_REMOTE_HOST_PORT=22"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------

:ExternalFunctions
:: Load External functions and programs:

::PSCP.EXE
:-------------------------------------------------------------------------------
::"%_PSCP_EXE%" (help function is just the command alone)
::IF "%_PSCP_INSTALLED%"=="YES" "%_PSCP_EXE%"
::-------------------------------------------------------------------------------
::GOTO SkipPscpFunction
SET "_QUIET_ERRORS=NO"
::SET "_QUIET_ERRORS=YES"
::-------------------------------------------------------------------------------
SET "_PSCP_INSTALLED=NO"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the just the command succeeds (same as help function in this case). Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
pscp -V >nul 2>&1 && SET "_PSCP_INSTALLED=YES" & SET "_PSCP_EXE=pscp" & REM ECHO pscp help command succeeded. & REM pscp help command returned success.
pscp -V >nul 2>"%_ERROR_OUTPUT_FILE%" || (
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
IF /I "%_PSCP_INSTALLED%"=="NO" (
	SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
	pscp.exe -V >nul 2>&1 && SET "_PSCP_INSTALLED=YES" & SET "_PSCP_EXE=pscp.exe" & REM ECHO pscp.exe help command succeeded. & REM pscp.exe help command returned success.
	pscp.exe -V >nul 2>"%_ERROR_OUTPUT_FILE%" || (
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
IF /I "%_PSCP_INSTALLED%"=="NO" SET "_PSCP_EXE=%ChocolateyInstall%\bin\PSCP.EXE"
IF /I EXIST "%_PSCP_EXE%" SET "_PSCP_INSTALLED=YES"
:: C:\ProgramData\chocolatey\lib\putty.portable\tools\PSCP.EXE
IF /I "%_PSCP_INSTALLED%"=="NO" SET "_PSCP_EXE=%ChocolateyInstall%\lib\putty.portable\tools\PSCP.EXE"
IF /I EXIST "%_PSCP_EXE%" SET "_PSCP_INSTALLED=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF /I "%_QUIET_ERRORS%"=="NO" (
	IF /I "%_PSCP_INSTALLED%"=="NO" (
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

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::ScriptMain
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 2: Build PSCP command & Run
:: Phase 3: Clean-up password storage file
:: Phase 4: Open local folder location (if Receive mode enabled)
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

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IF /I NOT "%_CALLED_FROM_SCRIPT%"=="ACTIVE" CLS

ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF /I "%_SEND_OR_RECEIVE%"=="SEND" (
	ECHO PSCP.EXE SENDING...
) ELSE IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
	ECHO PSCP.EXE RECEIVING...
) ELSE (
	ECHO:
	ECHO HORRIBLE ERROR
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Variable _SEND_OR_RECEIVE should be set to "SEND" or "RECEIVE"
	ECHO "%_SEND_OR_RECEIVE%"
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	GOTO END
)
ECHO -------------------------------------------------------------------------------

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Evaluate file path parameters

:: Get _LOCAL_FILE Name & eXtention, Drive letter & Path
FOR %%G IN ("%_LOCAL_FILE%") DO SET "_LOCAL_FILE_NAME=%%~nxG"
FOR %%G IN ("%_LOCAL_FILE%") DO SET "_LOCAL_FILE_PATH=%%~dpG"

IF NOT "%_PW_FILE%"=="" (
	:: Get _PW_FILE Name & eXtention, Drive letter & Path
	FOR %%G IN ("%_PW_FILE%") DO SET "_PW_FILE_NAME=%%~nxG"
	FOR %%G IN ("%_PW_FILE%") DO SET "_PW_FILE_PATH=%%~dpG"
)

:: Find if _LOCAL_FILE has a wildcard "*" in it.
:: "%_Variable:_SearchString=_ReplacementString%"
::ECHO File test:
::SET "_LOCAL_FILE=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\*.bat"
::SET "_LOCAL_FILE=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\CompareTo-Parent.bat"
REM ECHO DEBUGGING: _LOCAL_FILE = "%_LOCAL_FILE%"
IF /I NOT "%_LOCAL_FILE:**=%"=="%_LOCAL_FILE%" (
	REM _LOCAL_FILE contains an asterisk.
	SET "_LOCAL_FILE_WILDCARD=ENABLED"
) ELSE (
	REM _LOCAL_FILE does NOT contain an asterisk.
	SET "_LOCAL_FILE_WILDCARD=DISABLED"
)
REM ECHO DEBUGGING: _LOCAL_FILE_WILDCARD = %_LOCAL_FILE_WILDCARD%

:: Find if _REMOTE_FILE has a wildcard "*" in it.
:: "%_Variable:_SearchString=_ReplacementString%"
::ECHO File test:
::SET "_REMOTE_FILE=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\*.bat"
::SET "_REMOTE_FILE=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\Tools\CompareTo-Parent.bat"
REM ECHO DEBUGGING: _REMOTE_FILE = "%_REMOTE_FILE%"
IF /I NOT "%_REMOTE_FILE:**=%"=="%_REMOTE_FILE%" (
	REM _REMOTE_FILE contains an asterisk.
	SET "_REMOTE_FILE_WILDCARD=ENABLED"
) ELSE (
	REM _REMOTE_FILE does NOT contain an asterisk.
	SET "_REMOTE_FILE_WILDCARD=DISABLED"
)
REM ECHO DEBUGGING: _REMOTE_FILE_WILDCARD = %_REMOTE_FILE_WILDCARD%

:: Check if either path ends with a backslash "\" and remove it
REM ECHO DEBUGGING: _LOCAL_FILE = %_LOCAL_FILE%
:: https://ss64.com/nt/syntax-substring.html
:: %variable:~num_chars_to_skip%
:: %variable:~num_chars_to_skip,num_chars_to_keep%
:: A negative number will count backwards from the end of the string.
:: Get last character
SET "_LAST_CHAR=%_LOCAL_FILE:~-1%"
IF "%_LAST_CHAR%"=="\" (
	REM Get everything except the last character
	SET "_LOCAL_FILE=%_LOCAL_FILE:~0,-1%"
)
REM ECHO DEBUGGING: _LOCAL_FILE = %_LOCAL_FILE%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Check if local file exists first since that's the easiest to have user correct first

:: Check if file exists
REM ECHO DEBUGGING: Checking if local file/path exists.
IF /I "%_SEND_OR_RECEIVE%"=="SEND" (
	IF "%_LOCAL_FILE_WILDCARD%"=="DISABLED" (
		IF NOT EXIST "%_LOCAL_FILE%" (
			ECHO:
			ECHO PARAMETER NOT FOUND
			ECHO -------------------------------------------------------------------------------
			ECHO ERROR: Cannot find _LOCAL_FILE
			ECHO %_LOCAL_FILE%
			ECHO -------------------------------------------------------------------------------
			ECHO:
			PAUSE
			ECHO:
			GOTO END
		) ELSE (
			ECHO:
			IF "%_LOCAL_FILE_WILDCARD%"=="DISABLED" (
				ECHO Sending file "%_LOCAL_FILE%"
			) ELSE (
				ECHO Sending file^(s^) "%_LOCAL_FILE%"
			)
			ECHO:
			ECHO To "%_REMOTE_FILE%"
			ECHO:
		)
	) ELSE (
		ECHO:
		IF "%_LOCAL_FILE_WILDCARD%"=="DISABLED" (
			ECHO Sending file "%_LOCAL_FILE%"
		) ELSE (
			ECHO Sending file^(s^) "%_LOCAL_FILE%"
		)
		ECHO:
		ECHO To "%_REMOTE_FILE%"
		ECHO:
	)
) ELSE IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
	REM Check if receiving location exists
	IF NOT EXIST "%_LOCAL_FILE%" (
		ECHO:
		ECHO This path does not exist. ^(_LOCAL_FILE^)
		ECHO: 
		ECHO "%_LOCAL_FILE%"
		ECHO:
		CHOICE /M "Would you like to create it?"
		IF ERRORLEVEL 2 GOTO END & REM No.
		IF ERRORLEVEL 1 MKDIR "%_LOCAL_FILE%" && ECHO Directory successfully created. & REM Yes.
		ECHO:
		IF /I "%_REMOTE_FILE_WILDCARD%"=="DISABLED" (
			ECHO Retrieving file "%_REMOTE_FILE%"
		) ELSE (
			ECHO Retrieving file^(s^) "%_REMOTE_FILE%"
		)
		ECHO:
		ECHO To save at location "%_LOCAL_FILE%"
		ECHO:
	) ELSE (
		ECHO:
		IF /I "%_REMOTE_FILE_WILDCARD%"=="DISABLED" (
			ECHO Retrieving file "%_REMOTE_FILE%"
		) ELSE (
			ECHO Retrieving file^(s^) "%_REMOTE_FILE%"
		)
		ECHO:
		ECHO To save at location "%_LOCAL_FILE%"
		ECHO:
	)
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Get Remote Host address

IF "%_REMOTE_HOST%"=="" (
	REM ECHO Remote host can be IP or DNS address.
	REM ECHO:
	REM SET /P "_REMOTE_HOST=Please enter remote host: "
	REM ECHO:
	IF /I "%_SEND_OR_RECEIVE%"=="SEND" (
		REM ECHO To host "!_REMOTE_HOST!"
		SET /P "_REMOTE_HOST=To host: "
	) ELSE IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
		REM ECHO From host "!_REMOTE_HOST!"
		SET /P "_REMOTE_HOST=From host: "
	)
	ECHO:
) ELSE (
	IF /I "%_SEND_OR_RECEIVE%"=="SEND" (
		ECHO To host "%_REMOTE_HOST%"
	) ELSE IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
		ECHO From host "%_REMOTE_HOST%"
	)
	ECHO:
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Check if a port has been explicitly set

IF NOT "%_REMOTE_HOST_PORT%"=="" (
	ECHO Explicit port set: %_REMOTE_HOST_PORT%
	ECHO:
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Get remote host username to login with

IF "%_REMOTE_HOST_USERNAME%"=="" (
	SET /P "_REMOTE_HOST_USERNAME=Username: "
	ECHO:
	REM ECHO Username "!_REMOTE_HOST_USERNAME!"
	REM ECHO:
) ELSE (
	ECHO Username "%_REMOTE_HOST_USERNAME%"
	ECHO:
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Get Password for remote host

IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
	REM ECHO DEBUGGING: Password file preservation disabled. Cleaning-up any remaining files
) ELSE (
	REM ECHO DEBUGGING: Searching for _PW_FILE...
)

SET "_PW_VAR="

REM ECHO DEBUGGING: Checking "%_PW_FILE%"
IF NOT EXIST "%_PW_FILE%" (
	SET "_PW_FILE_NAME=password.txt"
	SET "_PW_FILE=%_PW_FILE_PATH%!_PW_FILE_NAME!"
) ELSE (
	IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		REM _PW_FILE exists, and password file preservation is disabled. Clean-up file.
		DEL /F /Q "%_PW_FILE%"
	)
)

REM ECHO DEBUGGING: Checking "%_PW_FILE%"
IF NOT EXIST "%_PW_FILE%" (
	SET "_PW_FILE_NAME=TEMPORARY_DELETE_ASAP.txt"
	SET "_PW_FILE=%_PW_FILE_PATH%!_PW_FILE_NAME!"
) ELSE (
	IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		REM _PW_FILE exists, and password file preservation is disabled. Clean-up file.
		DEL /F /Q "%_PW_FILE%"
	)
)

REM ECHO DEBUGGING: Checking "%_PW_FILE%"
IF NOT EXIST "%_PW_FILE%" (
	SET "_PW_FILE_NAME=password.txt"
	SET "_PW_FILE=%~dp0!_PW_FILE_NAME!"
) ELSE (
	IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		REM _PW_FILE exists, and password file preservation is disabled. Clean-up file.
		DEL /F /Q "%_PW_FILE%"
	)
)

REM ECHO DEBUGGING: Checking "%_PW_FILE%"
IF NOT EXIST "%_PW_FILE%" (
	SET "_PW_FILE_NAME=TEMPORARY_DELETE_ASAP.txt"
	SET "_PW_FILE=%~dp0!_PW_FILE_NAME!"
) ELSE (
	IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		REM _PW_FILE exists, and password file preservation is disabled. Clean-up file.
		DEL /F /Q "%_PW_FILE%"
	)
)

REM ECHO DEBUGGING: Checking "%_PW_FILE%"
IF NOT EXIST "%_PW_FILE%" (
	IF /I "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		ECHO Password preservation enabled. Password will be stored in a file for later use.
		ECHO Storage file to create "!_PW_FILE!"
		REM ECHO:
		REM >===============================================================================
		ECHO WARNING: This file will NOT be deleted until _DONT_DELETE_PW_FILE is set to OFF
		ECHO:
		SET /P "_PW_VAR=Please enter password: "
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		ECHO !_PW_VAR!> "!_PW_FILE!"
		ECHO:
	)
) ELSE (
	IF /I NOT "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
		REM _PW_FILE exists, and password file preservation is disabled. Clean-up file.
		DEL /F /Q "%_PW_FILE%"
	) ELSE (
		REM Password file already exists, so lets retrieve it
		REM SET "_PW_VAR_ORIG=%_PW_VAR%"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		REM If there are multiple lines in the file, SET /P will use the first line.
		SET /P _PW_VAR=<"%_PW_FILE%"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		REM SET "_PW_VAR=%_PW_VAR_ORIG%"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		REM If there are multiple lines in the file, FOR /F will use the last line.
		REM FOR /F "delims=" %%G IN (%_PW_FILE%) DO SET "_PW_VAR=%%G"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		REM SET "_PW_VAR=%_PW_VAR_ORIG%"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		REM If there are multiple lines in the file, FOR /F will use the last line.
		REM FOR /F "tokens=* delims=" %%G IN (%_PW_FILE%) DO SET "_PW_VAR=%%G"
		REM ECHO DEBUGGING: _PW_VAR = !_PW_VAR!
		ECHO Password retrieved from "%_PW_FILE%"
		ECHO:
	)
)

::===============================================================================
:: Phase 2: Build PSCP command & Run
::===============================================================================

:: PSCP - PuTTY
:: For help, just type pscp without any switches or parameters.

:: Using PSCP:
:: https://the.earth.li/~sgtatham/putty/0.60/htmldoc/Chapter5.html

:: To receive (a) file(s) from a remote server:

:: pscp [options] [user@]host:source target

:: So to copy the file /etc/hosts from the server example.com as user fred to the file c:\temp\example-hosts.txt, you would type:

:: pscp fred@example.com:/etc/hosts c:\temp\example-hosts.txt



:: To send (a) file(s) to a remote server:

:: pscp [options] source [source...] [user@]host:target

:: So to copy the local file c:\documents\foo.txt to the server example.com as user fred to the file /tmp/foo you would type:

:: pscp c:\documents\foo.txt fred@example.com:/tmp/foo



:: You can use wildcards to transfer multiple files in either direction, like this:

:: pscp c:\documents\*.doc fred@example.com:docfiles
:: pscp fred@example.com:source/*.c c:\source

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::PuTTY Secure Copy client
::Release 0.70
::Usage: pscp [options] [user@]host:source target
::       pscp [options] source [source...] [user@]host:target
::       pscp [options] -ls [user@]host:filespec
::::Options:
::  -V        print version information and exit
::  -pgpfp    print PGP key fingerprints and exit
::  -p        preserve file attributes
::  -q        quiet, don't show statistics
::  -r        copy directories recursively
::  -v        show verbose messages
::  -load sessname  Load settings from saved session
::  -P port   connect to specified port
::  -l user   connect with specified username
::  -pw passw login with specified password
::  -1 -2     force use of particular SSH protocol version
::  -4 -6     force use of IPv4 or IPv6
::  -C        enable compression
::  -i key    private key file for user authentication
::  -noagent  disable use of Pageant
::  -agent    enable use of Pageant
::  -hostkey aa:bb:cc:...
::            manually specify a host key (may be repeated)
::  -batch    disable all interactive prompts
::  -proxycmd command
::            use 'command' as local proxy
::  -unsafe   allow server-side wildcards (DANGEROUS)
::  -sftp     force use of SFTP protocol
::  -scp      force use of SCP protocol
::  -sshlog file
::  -sshrawlog file
::            log protocol details to a file

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: -------------------------------------------------------------------------------

GOTO SkipExamples
REM ECHO DEBUGGING: pscp examples

:: Get Help:
pscp
"%_PSCP_EXE%"

:: Get pscp version:
pscp -V
"%_PSCP_EXE%" -V

:: Copy "lan.lists" to /etc/pihole:
pscp "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\lan.list" pi@192.168.0.200:/home/pi/lan.list


:: Copy everything from the Pi Documents folder to "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server":
pscp pi@192.168.0.200:/home/pi/Documents/* "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server"
"%_PSCP_EXE%" pi@192.168.0.200:/home/pi/Documents/* "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server"


:: Copy DynDNS-NameSilo-RottenEggs.py file to /home/pi/DynDNS:
pscp "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS\DynDNS-NameSilo-RottenEggs.py" pi@my.pi:/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs.py
"%_PSCP_EXE%" "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS\DynDNS-NameSilo-RottenEggs.py" pi@my.pi:/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs.py


:: Copy DynDNS-NameSilo-RottenEggs-LogCleanup.sh file to /home/pi/DynDNS:
pscp "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS\DynDNS-NameSilo-RottenEggs-LogCleanup.sh" pi@my.pi:/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LogCleanup.sh


:: Copy all log files from  /home/pi/DynDNS:
pscp pi@my.pi:/home/pi/DynDNS/*.log "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS"


:: Copy app.py to pipsqueak dev server:
pscp "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\docker-django\app.py" g@192.168.0.201:/home/g/pipsqueak/docker-django/app.py
::pscp -pw password "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\docker-django\app.py" g@192.168.0.201:/home/g/pipsqueak/docker-django/app.py
pscp -pw phenTomYserBice "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\docker-django\app.py" g@192.168.0.201:/home/g/pipsqueak/docker-django/app.py


:: Run As Administrator
:: Copy 'pipsqueak' folder to our local machine:
pscp -r g@192.168.0.201:/home/g/pipsqueak/* "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\pipsqueak"
::pscp -r -pw password g@192.168.0.201:/home/g/pipsqueak/* "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\pipsqueak"
pscp -r -pw phenTomYserBice g@192.168.0.201:/home/g/pipsqueak/* "%UserProfile%\Documents\Pipsqeak\Pipsqueak-Server\pipsqueak\"
pscp -r -pw phenTomYserBice g@192.168.0.201:/home/g/pipsqueak/* "$env:UserProfile\Documents\Pipsqeak\Pipsqueak-Server\pipsqueak\"

:SkipExamples

:: -------------------------------------------------------------------------------

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Construct PSCP.EXE command

REM ECHO DEBUGGING: Constructing PSCP.EXE command

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_PSCP_COMMAND=%_PSCP_EXE%"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::  -r        copy directories recursively
IF /I "%_LOCAL_FILE_WILDCARD%"=="ENABLED" (
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% -r"
) ELSE IF /I "%_REMOTE_FILE_WILDCARD%"=="ENABLED" (
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% -r"
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::  -v        show verbose messages
REM ECHO DEBUGGING: _PSCP_COMMAND = %_PSCP_COMMAND%
REM ECHO DEBUGGING: Enabling -v switch in pscp command for verbose messages: & SET "_PSCP_COMMAND=%_PSCP_COMMAND% -v"
REM ECHO DEBUGGING: _PSCP_COMMAND = %_PSCP_COMMAND%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::  -P port   connect to specified port
IF NOT "%_REMOTE_HOST_PORT%"=="" (
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% -P %_REMOTE_HOST_PORT%"
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::  -pw passw login with specified password
IF NOT "%_PW_VAR%"=="" (
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% -pw %_PW_VAR%"
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: [user@]host:/source/or/target
SET "_REMOTE_FILE_PATH=%_REMOTE_HOST_USERNAME%"
SET "_REMOTE_FILE_PATH=%_REMOTE_FILE_PATH%@%_REMOTE_HOST%"
SET "_REMOTE_FILE_PATH=%_REMOTE_FILE_PATH%:%_REMOTE_FILE%"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IF /I "%_SEND_OR_RECEIVE%"=="SEND" (
	REM To send (a) file(s) to a remote server:
	REM pscp [options] source [source...] [user@]host:target
	REM So to copy the local file c:\documents\foo.txt to the server example.com as user fred to the file /tmp/foo you would type:
	REM pscp c:\documents\foo.txt fred@example.com:/tmp/foo
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% "%_LOCAL_FILE%" "%_REMOTE_FILE_PATH%""
	REM SET "_PSCP_COMMAND=%_PSCP_COMMAND% "%_LOCAL_FILE%" %_REMOTE_FILE_PATH%"
) ELSE IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
	REM To receive (a) file(s) from a remote server:
	REM pscp [options] [user@]host:source target
	REM So to copy the file /etc/hosts from the server example.com as user fred to the file c:\temp\example-hosts.txt, you would type:
	REM pscp fred@example.com:/etc/hosts c:\temp\example-hosts.txt
	SET "_PSCP_COMMAND=%_PSCP_COMMAND% "%_REMOTE_FILE_PATH%" "%_LOCAL_FILE%""
	REM SET "_PSCP_COMMAND=%_PSCP_COMMAND% %_REMOTE_FILE_PATH% "%_LOCAL_FILE%""
) ELSE (
	ECHO HORRIBLE ERROR:
	ECHO Variable _SEND_OR_RECEIVE should be set to "SEND" or "RECEIVE". Aborting...
	GOTO END
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Execute command

ECHO -------------------------------------------------------------------------------
ECHO:
ECHO Executing command:
ECHO %_PSCP_COMMAND%
ECHO:
PAUSE

%_PSCP_COMMAND%

IF %ERRORLEVEL% EQU 0 (
	IF ERRORLEVEL 0 (
		REM ECHO DEBUGGING: No execution errors detected.
	) ELSE (
		ECHO:
		ECHO pscp execution errors detected^!
		PAUSE
	)
) ELSE (
	ECHO:
	ECHO pscp execution errors detected^!
	PAUSE
)

::ECHO -------------------------------------------------------------------------------

::===============================================================================
:: Phase 3: Clean-up password storage file
::===============================================================================

IF /I "%_DONT_DELETE_PW_FILE%"=="PRESERVE" (
	IF EXIST "%_PW_FILE%" (
		DEL /Q "%_PW_FILE%" & REM Clean-up temp file ASAP.
	)
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::ECHO -------------------------------------------------------------------------------

::===============================================================================
:: Phase 4: Open local folder location (if Receive mode enabled)
::===============================================================================

IF /I "%_SEND_OR_RECEIVE%"=="RECEIVE" (
	ECHO:
	ECHO Files copied to local path: "%_LOCAL_FILE%"
	ECHO:
	REM https://ss64.com/nt/choice.html
	CHOICE /M "Open folder path now?"
	IF ERRORLEVEL 2 GOTO Footer & REM ECHO DEBUGGING: No chosen. & REM No.
	IF ERRORLEVEL 1 EXPLORER "%_LOCAL_FILE%" & REM ECHO DEBUGGING: Yes chosen. & REM Yes.
)

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

:: End Footer

REM -------------------------------------------------------------------------------

GOTO SkipFunctions
:: Declare Functions
:DefineFunctions
:-------------------------------------------------------------------------------
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions
