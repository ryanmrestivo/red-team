@ECHO OFF

REM -------------------------------------------------------------------------------

:Parameters

:: Param1 = Folder location to pull branch to

SET "_FOLDER_LOCATION=E:\Backup And Restore Tools2"
SET "_FOLDER_LOCATION=E:\testing\demo\test\Backup And Restore Tools2"
SET "_FOLDER_LOCATION=%UserProfile%\Desktop\DEMO\foo\bar"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = GitHub Repo to pull from

SET "_GITHUB_REPO=https://github.com/Kerbalnut/Batch-Tools-SysAdmin.git"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param3 = Branch to pull

SET "_BRANCH=backup-and-restore"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Parameters

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin ExternalFunctions block.

:ExternalFunctions
:: Load External functions and programs:

::Git
:-------------------------------------------------------------------------------
::"%_GIT_EXE%" (help function is just the command alone)
::IF "%_GIT_INSTALLED%"=="YES" "%_GIT_EXE%"
::-------------------------------------------------------------------------------
:: Parameters
::GOTO SkipGitFunction
SET "_QUIET_ERRORS=NO"
::SET "_QUIET_ERRORS=YES"
::-------------------------------------------------------------------------------
SET "_GIT_INSTALLED=NO"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Check if the just the command succeeds (same as help function in this case). Redirect text output to NULL but redirect error output to temp file.
SET "_ERROR_OUTPUT_FILE=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.txt"
git --version >nul 2>&1 && SET "_GIT_INSTALLED=YES" & SET "_GIT_EXE=git" & REM ECHO git help command succeeded. & REM git help command returned success.
git --version >nul 2>"%_ERROR_OUTPUT_FILE%" || (
	REM SET "_GIT_INSTALLED=NO"
	IF /I NOT "%_QUIET_ERRORS%"=="YES" (
		ECHO git help command failed. & REM git help command failed.
		ECHO Error output text:
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		TYPE "%_ERROR_OUTPUT_FILE%"
		ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		ECHO:
	)
)
IF EXIST "%_ERROR_OUTPUT_FILE%" DEL /Q "%_ERROR_OUTPUT_FILE%" & REM Clean-up temp file ASAP.
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: C:\Program Files\Git\bin\git.exe
IF /I "%_GIT_INSTALLED%"=="NO" SET "_GIT_EXE=%ProgramFiles%\Git\bin\git.exe"
IF /I EXIST "%_GIT_EXE%" SET "_GIT_INSTALLED=YES"
:: C:\ProgramData\chocolatey\lib\putty.portable\tools\Git
IF /I "%_GIT_INSTALLED%"=="NO" SET "_GIT_EXE=%ProgramFiles(x86)%\Git\bin\git.exe"
IF /I EXIST "%_GIT_EXE%" SET "_GIT_INSTALLED=YES"
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IF /I "%_QUIET_ERRORS%"=="NO" (
	IF /I "%_GIT_INSTALLED%"=="NO" (
		ECHO:
		ECHO EXTERNAL FUNCTION NOT FOUND
		ECHO -------------------------------------------------------------------------------
		ECHO ERROR: Cannot find Git
		REM ECHO %_GIT_EXE%
		ECHO:
		ECHO Chocolatey ^(Run As Administrator^)
		ECHO ^> choco install tortoisegit -y
		ECHO or
		ECHO ^> choco install github-desktop -y
		ECHO:
		ECHO https://chocolatey.org/packages/TortoiseGit
		ECHO:
		ECHO https://chocolatey.org/packages/github-desktop
		ECHO -------------------------------------------------------------------------------
		ECHO:
		PAUSE
		ECHO:
		GOTO END
	)
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Git
:: "%_GIT_EXE%"
:SkipGitFunction
:-------------------------------------------------------------------------------

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Create directory if it doesn't exist

ECHO New pull location = "%_FOLDER_LOCATION%"
ECHO:
::PAUSE

IF NOT EXIST "%_FOLDER_LOCATION%" MKDIR "%_FOLDER_LOCATION%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Navigate to directory

CD /D "%_FOLDER_LOCATION%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::Thanks to:
::https://stackoverflow.com/a/7349740/2449416

:: To clone a branch without fetching other branches:

::git init
::git remote add -t %_BRANCH% -f origin %_GITHUB_REPO%
::git checkout %_BRANCH%

ECHO DEBUGGING: New pull location = "%_FOLDER_LOCATION%"
ECHO DEBUGGING: Current location = "%CD%"
ECHO DEBUGGING: _GIT_EXE = "%_GIT_EXE%"
PAUSE

ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"%_GIT_EXE%" init
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"%_GIT_EXE%" remote add -t %_BRANCH% -f origin %_GITHUB_REPO%
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"%_GIT_EXE%" checkout %_BRANCH%
ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Open the newly pulled folder

EXPLORER "%_FOLDER_LOCATION%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:Footer
:END
::ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO :EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.

