@ECHO OFF

ECHO:
ECHO Boxstarter Template ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
REM Bugfix: cannot use :: for comments within IF statement, instead use REM
ECHO:

ECHO 1: %1
ECHO 2: %2
ECHO 3: %3

ECHO:

EXIT /B
