@ECHO OFF

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: https://ss64.com/nt/syntax-args.html
SET "_HOME_PATH=%~dp0"

SET "_HOME_NAME=%~n0"

:: https://ss64.com/nt/syntax-substring.html
:: Exctract everything BUT the last 14 characters
SET "_SOURCE_NAME=%_HOME_NAME:~0,-14%.bat"
::      Track-SentHistory_ProductionRun.bat
::                       123456789012345678

SET "_SOURCE_SCRIPT=%_HOME_PATH%%_SOURCE_NAME%"

:: Create "production" copy in %Temp% directory
SET "_PRODUCTION_PATH=%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%"

MKDIR "%_PRODUCTION_PATH%"

SET "_PRODUCTION_SCRIPT=%_PRODUCTION_PATH%\%_SOURCE_NAME%"

COPY "%_SOURCE_SCRIPT%" "%_PRODUCTION_SCRIPT%"

SET "_PARAMETERS=%_HOME_PATH%"
CD /D "%_HOME_PATH%"

ECHO:
ECHO Running script = "%_PRODUCTION_SCRIPT%"
ECHO:
ECHO CD = "%CD%"
ECHO:
ECHO PRODUCTION RUN STARTING
ECHO:
PAUSE
REM ===============================================================================

CMD.EXE /C ""%_PRODUCTION_SCRIPT%" "%_PARAMETERS%""

REM ===============================================================================
ECHO:
ECHO Clean-up %~nx0 . . . 

DEL "%_PRODUCTION_SCRIPT%"
RMDIR /S /Q "%_PRODUCTION_PATH%"

ECHO:
ECHO %_PRODUCTION_PATH% production run deleted.
ECHO:
ECHO End %~nx0
ECHO:
PAUSE
EXIT /B
