@ECHO OFF
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :Parameters
:: 2. :Main
:: 3. :Footer
:: 4. :DefineFunctions

ECHO DEBUGGING: Begin Parameters block.

::-------------------------------------------------------------------------------

:Parameters

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1

SET "_REMOTE_HOST="

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = Drive letter on remote computer to open
:: E.g.
:: C
:: D

SET "_DRIVE_LETTER="

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param3 = Folder path on remote share to open
:: E.g.
:: \Users\<username>\Documents\
:: Users\<username>\Documents\
:: C:\Users\<username>\Documents\

SET "_FILE_PATH="

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::End Parameters

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Get Parameters: Remote Host
:: Phase 2: Evaluate Parameters: Drive Letter
:: Phase 3: Evaluate Parameters: %_FILE_PATH%
:: Phase 4: Open windows explorer to remote administrative share
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Get Parameters: Remote Host
::===============================================================================

ECHO %~nx0
ECHO:
ECHO Access Administrative shares on a remote system.

:: -------------------------------------------------------------------------------

:GetRemoteHost
ECHO:
IF "%_REMOTE_HOST%"=="" (
	SET /P "_REMOTE_HOST=Enter Name or IP of remote host (e.g. server.local, 192.168.0.11): "
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Check DNS for name resolution

SET "_ERROR_OUTPUT_FILE=%TEMP%\%~n0_%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"

NSLOOKUP "%_REMOTE_HOST%" >nul 2>"%_ERROR_OUTPUT_FILE%"

FOR %%G IN ("%_ERROR_OUTPUT_FILE%") DO SET "_ERROR_OUTPUT_FILE_SIZE=%%~zG"
SET /A "_ERROR_OUTPUT_FILE_SIZE_KB=%_ERROR_OUTPUT_FILE_SIZE%/1024"

IF %_ERROR_OUTPUT_FILE_SIZE% GTR 0 (
	REM _ERROR_OUTPUT_FILE has contents, so lets retrieve it
	ECHO DEBUGGING: %%_ERROR_OUTPUT_FILE%% = "%_ERROR_OUTPUT_FILE%"
	REM If there are multiple lines in the file, SET /P will use the first line.
	SET /P _ERROR_TEXT=<"%_ERROR_OUTPUT_FILE%"
	IF "!_ERROR_TEXT!"=="Non-authoritative answer:" (
		ECHO DEBUGGING: "Non-authoritative answer:" error detected, ignoring ^& continuing. & PAUSE
	) ELSE (
		ECHO:
		ECHO Error: "%_REMOTE_HOST%" could not be looked up by DNS.
		ECHO:
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO:
		PAUSE
		REM CLS
		SET "_REMOTE_HOST="
		REM GOTO GetRemoteHost
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" (
	REM _ERROR_OUTPUT_FILE exists and we're done using it, clean-up file.
	DEL /F /Q "%_ERROR_OUTPUT_FILE%"
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Ping IP address

::CALL :CheckLink "%_REMOTE_HOST%" silent

IF "%_LinkState%"=="down" (
	ECHO:
	ECHO Error: "%_REMOTE_HOST%" not responding to ICMP pings.
	ECHO:
	PAUSE
	REM CLS
	REM GOTO GetRemoteHost
)

::===============================================================================
:: Phase 2: Evaluate Parameters: Drive Letter
::===============================================================================

IF "%_DRIVE_LETTER%"=="" (
	IF NOT "%_FILE_PATH%"=="" (
		ECHO DEBUGGING: %%_FILE_PATH%% = "%_FILE_PATH%"
		REM Get _FILE_PATH Drive letter
		FOR %%G IN ("%_FILE_PATH%") DO SET "_FILE_PATH_DRIVE_LETTER=%%~dG"
		REM Use that in place of _DRIVE_LETTER
		SET "_DRIVE_LETTER=!_FILE_PATH_DRIVE_LETTER!"
		ECHO DEBUGGING: ^^!_DRIVE_LETTER^^! = "!_DRIVE_LETTER!"
	)
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:GetDriveLetter
ECHO:
IF "%_DRIVE_LETTER%"=="" (
	SET /P "_DRIVE_LETTER=Enter Drive letter to connect to (e.g. C, D): "
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Check if string is longer than 1 character

IF "%_DRIVE_LETTER%"=="" (
	ECHO:
	ECHO Error: Drive letter empty.
	ECHO:
	ECHO "%%_DRIVE_LETTER%%" = "%_DRIVE_LETTER%"
	ECHO:
	PAUSE
	CLS
	GOTO GetDriveLetter
)

CALL :StrLen "%_DRIVE_LETTER%" _DRIVE_LETTER_LENGTH

ECHO DEBUGGING: %%_DRIVE_LETTER%% string length: %_DRIVE_LETTER_LENGTH%

IF %_DRIVE_LETTER_LENGTH% GTR 1 (
	ECHO DEBUGGING: %%_DRIVE_LETTER%% = "%_DRIVE_LETTER%"
	REM Get var substring: https://ss64.com/nt/syntax-substring.html syntax = %variable:~start_index,end_index%
	SET "_FIRST_CHAR=%_DRIVE_LETTER:~0,1%"
	SET "_DRIVE_LETTER=!_FIRST_CHAR!"
	ECHO DEBUGGING: ^^!_DRIVE_LETTER^^! = "!_DRIVE_LETTER!"
)

ECHO DEBUGGING: %%_DRIVE_LETTER%% = "%_DRIVE_LETTER%"
CALL :GetIfPathIsDriveRoot "%_DRIVE_LETTER%"
SET "_DRIVE_LETTER=%_DRIVE_LETTER_CHAR%"
ECHO DEBUGGING: %%_DRIVE_LETTER%% = "%_DRIVE_LETTER%"

IF "%_IS_DRIVE_LETTER%"=="NO" (
	ECHO:
	ECHO Error: Drive letter failure.
	ECHO:
	ECHO "%%_DRIVE_LETTER%%" = "%_DRIVE_LETTER%"
	ECHO:
	PAUSE
	CLS
	GOTO GetDriveLetter
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 3: Evaluate Parameters: %_FILE_PATH%
::===============================================================================

IF NOT "%_FILE_PATH%"=="" (
	ECHO DEBUGGING: %%_FILE_PATH%% = "%_FILE_PATH%"
	REM %variable:StrToFind=NewStr% https://ss64.com/nt/syntax-replace.html
	SET "_NO_COLON=%_FILE_PATH::=%"
	ECHO DEBUGGING: ^^!_NO_COLON^^! = "!_NO_COLON!"
	IF "%_FILE_PATH%"=="!_NO_COLON!" (
		SET "_FIRST_CHAR=%_FILE_PATH:~0,1%"
		IF NOT "!_FIRST_CHAR!"=="\" SET "_FILE_PATH=\%_FILE_PATH%"	
	)
	REM Get _FILE_PATH Path & Name (remove drive letter if it exists
	FOR %%G IN ("!_FILE_PATH!") DO SET "_FILE_PATH_PATH=%%~pnG"
	SET "_FILE_PATH=!_FILE_PATH_PATH!"
	ECHO DEBUGGING: ^^!_FILE_PATH^^! = "!_FILE_PATH!"
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 4: Open windows explorer to remote administrative share
::===============================================================================

ECHO:
ECHO Loading . . . 
ECHO:

ECHO DEBUGGING: EXPLORER \\%_REMOTE_HOST%\%_DRIVE_LETTER%$%_FILE_PATH% & ECHO: & PAUSE
	
EXPLORER \\%_REMOTE_HOST%\%_DRIVE_LETTER%$%_FILE_PATH%

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
::PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.

:: End Footer

REM -------------------------------------------------------------------------------

ECHO DEBUGGING: Begin DefineFunctions block.

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :StrLen
:: 2. :UpCase
:: 3. :CheckLink
:: 4. :GetIfPathIsDriveRoot 

GOTO SkipFunctions
:-------------------------------------------------------------------------------
:StrLen  StrVar  [RtnVar]
:: strLen String [RtnVar]
::             -- String  The string to be measured, surround in quotes if it contains spaces.
::             -- RtnVar  An optional variable to be used to return the string length.
:: Example:
::CALL :StrLen "%_INPUT_STRING%" _DRIVE_LETTER_LENGTH
::ECHO %_DRIVE_LETTER_LENGTH%
:: Thanks to dbenham from StackOverflow:
::https://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file#5841587
:: Thanks to SS64.com:
::https://ss64.com/nt/syntax-strlen.html
::
:: Computes the length of string in variable StrVar
:: and stores the result in variable RtnVar.
:: If RtnVar is is not specified, then prints the length to stdout.
::
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO DEBUGGING: Starting :StrLen function.
(
  SETLOCAL EnableDelayedExpansion
  ECHO DEBUGGING: Param1 = StrVar: "%~1"
  ECHO DEBUGGING: Param2 = RtnVar: "%~2"
  REM Add a single # character to our input string.
  SET "s=#%~1"
  SET "len=0"
  ECHO DEBUGGING: ^^!s^^! = !s!
  REM Iterate through each number in this set:
  FOR %%P IN (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) DO (
    ECHO DEBUGGING: P = %%P
	REM Get var substring: https://ss64.com/nt/syntax-substring.html syntax = %variable:~start_index,end_index%
	REM If s string is longer than P number:
    IF "!s:~%%P,1!" NEQ "" (
      ECHO DEBUGGING: ^^!s^^! = !s!
	  REM Add P number to len length:
      SET /A "len+=%%P"
	  REM var substring syntax: %variable:~start_index% Remove P number of characters from the start of s string.
      SET "s=!s:~%%P!"
	  ECHO DEBUGGING: ^^!s^^! = !s!
    )
  )
  ECHO DEBUGGING: ^^!s^^! = !s!
  ECHO DEBUGGING: ^^!len^^! = !len!
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO DEBUGGING: Ending :StrLen function. & ECHO:
(
  ENDLOCAL
  IF "%~2" EQU "" (ECHO %len%) ELSE SET "%~2=%len%"
  EXIT /B
)
:-------------------------------------------------------------------------------
:UpCase InputString
::CALL :UpCase "%_INPUT_STRING%"
:: Thanks to:
::https://www.robvanderwoude.com/battech_convertcase.php
:: Outputs:
:: "%_UPCASE_STRING%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@ECHO OFF
SETLOCAL
ECHO DEBUGGING: Starting :UpCase function. ^(%~1^)
SET "_INPUT_STRING=%~1"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF NOT "%_INPUT_STRING%"=="" (
	REM Subroutine to convert variable _INPUT_STRING to all UPPER CASE.
	FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "_INPUT_STRING=%%_INPUT_STRING:%%~i%%"
) ELSE (
	SET "_INPUT_STRING="
)
SET "_OUTPUT_STRING=%_INPUT_STRING%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO DEBUGGING: Ending :UpCase function. ^(%_OUTPUT_STRING%^)
ENDLOCAL & SET "_UPCASE_STRING=%_OUTPUT_STRING%"
::EXIT /B
GOTO:EOF
:-------------------------------------------------------------------------------
:CheckLink IPorDNSaddress [QuietMode]
::CALL :CheckLink "%_IP_ADDR_OR_DNS%"
::CALL :CheckLink "%_IP_ADDR_OR_DNS%" quiet
:: Check address for ICMP ping response packets
:: http://stackoverflow.com/questions/3050898/how-to-check-if-ping-responded-or-not-in-a-batch-file
:: thanks to paxdiablo for checklink.cmd
:: Outputs:
:: "%_LinkState%" Either "down" or "up"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@SETLOCAL EnableExtensions EnableDelayedExpansion
@ECHO OFF
SET "ipaddr=%~1"
SET "_QUIET=%~2"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SET "_SILENT_MODE=OFF"
IF /I "%_QUIET%"=="quiet" SET "_SILENT_MODE=ON"
IF /I "%_QUIET%"=="silent" SET "_SILENT_MODE=ON"
SET "_loopcount=0"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF /I "%_SILENT_MODE%"=="OFF" ECHO Testing address: %ipaddr%
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:loop
SET "state=down"
FOR /F "tokens=5,7" %%a IN ('PING -n 1 !ipaddr!') DO (
    IF "x%%a"=="xReceived" IF "x%%b"=="x1," SET "state=up"
)
IF /I "%_SILENT_MODE%"=="OFF" ECHO Link is !state!
REM --> test networking hardware capability
PING -n 6 127.0.0.1 >nul: 2>nul:
IF "!state!"=="down" (
	IF /I "%_SILENT_MODE%"=="ON" (
		ENDLOCAL & SET "_LinkState=%state%" & EXIT /B
	)
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
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_LinkState=%state%"
EXIT /B
:-------------------------------------------------------------------------------
:GetIfPathIsDriveRoot "Path:\To\Check"
::CALL :GetIfPathIsDriveRoot "%_PATH_TO_CHECK%"
::ECHO "%_IS_DRIVE_LETTER%"
::ECHO "%_DRIVE_LETTER_PATH%"
::ECHO "%_DRIVE_LETTER_CHAR%"
::Bugfix: If _DEST is just a drive letter e.g. G:\ robocopy will fail if it has quotes e.g. "G:\"
:: Outputs:
:: "%_IS_DRIVE_LETTER%" Returns if the input path is just a drive letter, e.g. "YES" or "NO"
:: "%_DRIVE_LETTER_PATH%" Returns 3-character drive path, e.g. "G:\" or "H:\"
:: "%_DRIVE_LETTER_CHAR%" Returns 1-character drive letter, e.g. "G" or "H"
:: Dependencies are :UpCase
@ECHO OFF
SETLOCAL
ECHO DEBUGGING: Starting :GetIfPathIsDriveRoot function. ^(%~1^)
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
:: Get 1st char of _LETTER_INPUT
:: %variable:~num_chars_to_skip,num_chars_to_keep%
SET "_FIRST_CHAR=%_LETTER_INPUT:~0,1%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Verify we have a letter selected
SET "_LETTER_CONFIRMED=NO"
FOR %%G IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
	IF /I "%_FIRST_CHAR%"=="%%G" (
		SET "_LETTER_CONFIRMED=YES"
	)
)
IF "%_LETTER_CONFIRMED%"=="NO" (
	SET "_DRIVE_LETTER=NO"
	SET "_FIRST_CHAR="
) ELSE (
	SET "_DRIVE_LETTER=YES"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Uppercase our drive letter
ECHO DEBUGGING: Call :UpCase function to uppercase %%_FIRST_CHAR%%
ECHO DEBUGGING:    %%_FIRST_CHAR%% = "%_FIRST_CHAR%"
CALL :UpCase "%_FIRST_CHAR%"
SET "_FORMATTED_LETTER=%_UPCASE_STRING%"
ECHO DEBUGGING: %%_UPCASE_STRING%% = "%_UPCASE_STRING%"
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Make 3-character _DRIVE_LETTER_OUTPUT, for _DRIVE_LETTER_PATH return var
:: %variable:~num_chars_to_skip,num_chars_to_keep%
IF "%_LETTER_CONFIRMED%"=="NO" (
	SET "_DRIVE_LETTER_OUTPUT="
) ELSE (
	SET "_DRIVE_LETTER_OUTPUT=%_FORMATTED_LETTER%:\"
)
:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO DEBUGGING: Ending :GetIfPathIsDriveRoot function. ^(%_DRIVE_LETTER%^)
ENDLOCAL & SET "_IS_DRIVE_LETTER=%_DRIVE_LETTER%" & SET "_DRIVE_LETTER_PATH=%_DRIVE_LETTER_OUTPUT%" & SET "_DRIVE_LETTER_CHAR=%_FORMATTED_LETTER%"
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions

