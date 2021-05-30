@ECHO OFF

ECHO:
ECHO Boxstarter Template ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
REM Bugfix: cannot use :: for comments within IF statement, instead use REM
ECHO:

ECHO Calling Test-ParameterWithSpaces.bat

::PAUSE

CALL %~dp0\Test-ParameterWithSpaces.bat One "C:\Path with spaces\test.txt" Third

ECHO:

PAUSE

EXIT /B
