@ECHO OFF
SETLOCAL EnableDelayedExpansion

::Index: 
:: 1. :Header
:: 2. :Parameters
:: 3. :Main
:: 4. :DefineFunctions
:: 5. :Footer

REM Bugfix: Use "REM ECHO DEBUG*ING: " instead of "::ECHO DEBUG*ING: " to comment-out debugging lines, in case any are within IF statements.
REM ECHO DEBUGGING: Begin RunAsAdministrator block.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:Header
ECHO:
ECHO Script name ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
ECHO Current directory: %CD% & REM The path of the currently selected directory.
ECHO:

SET "_ORIG_DIR=%CD%
CD /D %~dp0 & REM The drive letter and path of this script's location.

SET "_PRODUCTION_INPUT=%~1" & REM %~1   Expand %1 removing any surrounding quotes (")
IF NOT "%_PRODUCTION_INPUT%"=="" (
	REM Use input parameters.
	ECHO Production input = "%_PRODUCTION_INPUT%"
	REM Doesn't work: SET "%~dp0=%_PRODUCTION_INPUT%"
	CD /D "%_PRODUCTION_INPUT%"
	ECHO:
	ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
	ECHO Current directory: %CD% & REM (Doesn't work): The path of the currently selected directory.
	ECHO Current directory: !CD! & REM The path of the currently selected directory.
	ECHO:
	PAUSE
	ECHO:
	REM Bugfix: cannot use :: for comments within IF statement, instead use REM
	REM Bugfix: cannot use ECHO( for newlines within IF statement, instead use ECHO. or ECHO: 
)

:: End Header

REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin Parameters block.

:Parameters

CD ..
SET "_CSV_PATH=%CD%\Sent\Sent-History.csv"
::CD %_ORIG_DIR%

ECHO CSV path:
ECHO %_CSV_PATH%
ECHO:

:: Date applied:,Fancy Date:,Company:,Position:,Attachment:,URL:
::SET "_CSV_PATH=%USERPROFILE%\Documents\SpiderOak Hive\Resume\Sent\Sent-History.csv"

ECHO CSV path:
ECHO %_CSV_PATH%
ECHO:
::PAUSE
ECHO:

:: End Parameters

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main

REM ECHO DEBUGGING: Beginning Main execution block.

::Index of Main:

::===============================================================================
:: Phase 1: Evaluate Parameters
:: Phase 1: Initialize
::===============================================================================

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

::===============================================================================
:: Phase 1: Evaluate Parameters
::===============================================================================

:: Framework demo
::CLS
::ECHO ===============================================================================
ECHO ^|=============================================================================^|
ECHO ^|                                                                             ^|
ECHO ^|=============================================================================^|
::ECHO ===============================================================================

:: -------------------------------------------------------------------------------

GOTO Initialize

:: -------------------------------------------------------------------------------

:: -------------------------------------------------------------------------------

:: ===============================================================================
:: -------------------------------------------------------------------------------
:: -------------------------------------------------------------------------------

::===============================================================================
:: Phase 1: Initialize
::===============================================================================

:Initialize

CALL :GetDate
SET "_START_TIME_FORMATTED=%_FORMATTED_TIME%"

SET "_START_TIME=%TIME%"
::SET "_START_TIME=20-29-36" & REM Test time: " 8:29:36 PM"
CALL :ConvertTimeToSeconds "%_START_TIME%"
::Also works: CALL :ConvertTimeToSeconds "%_SORTABLE_TIME%"
SET "_START_TIME_SECS=%_TIME_SECONDS%"

SET "_START_DATE=%DATE%"
REM SET "_START_DATE=Fri 04/06/2018"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Setup for Weekly Counts

SET "_SHOW_WEEKLY=NARP"
:: Bugfix: Do not set variable values to "ON" or "OFF", you will get weird behavior

GOTO Refresh

:: -------------------------------------------------------------------------------
:: -------------------------------------------------------------------------------

:InitWholeWeekFunc

::SET "_SHOW_WEEKLY=YARP"

IF "%_SHOW_WEEKLY%"=="NARP" (
	SET "_SHOW_WEEKLY=YARP"
) ELSE (
	SET "_SHOW_WEEKLY=NARP"
	GOTO Refresh
)

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_DOW=%DATE:~0,3%"
::ECHO Day-of-Week = %_DOW%

:: Fill in current day's DoW mark with blanks
SET "_MON_TODAY= "
SET "_TUE_TODAY= "
SET "_WED_TODAY= "
SET "_THU_TODAY= "
SET "_FRI_TODAY= "
SET "_SAT_TODAY= "
SET "_SUN_TODAY= "

:: Mark the top of the Day-of-Week current day
IF /I %_DOW%==Mon (
	SET _DOW_VAL=1
	SET "_MON_TODAY=X"
	REM ECHO Today is Monday
) ELSE IF /I %_DOW%==Tue (
		SET _DOW_VAL=2
		SET "_TUE_TODAY=X"
		REM ECHO Today is Tuesday
	) ELSE IF /I %_DOW%==Wed (
			SET _DOW_VAL=3
			SET "_WED_TODAY=X"
			REM ECHO Today is Wednesday
		) ELSE IF /I %_DOW%==Thu (
				SET _DOW_VAL=4
				SET "_THU_TODAY=X"
				REM ECHO Today is Thursday
			) ELSE IF /I %_DOW%==Fri (
					SET _DOW_VAL=5
					SET "_FRI_TODAY=X"
					REM ECHO Today is Friday
				) ELSE IF /I %_DOW%==Sat (
						SET _DOW_VAL=6
						SET "_SAT_TODAY=X"
						REM ECHO Today is Saturday
					) ELSE IF /I %_DOW%==Sun (
							SET _DOW_VAL=7
							SET "_SUN_TODAY=X"
							REM ECHO Today is Sunday
						) ELSE ( 
							ECHO ERROR in finding today's Day-of-Week...
						)
					)
				)
			)
		)
	)
)
::ECHO:
::ECHO DoW Value = %_DOW_VAL%
::ECHO:

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET /A _SUN_DOW_VAL=7-%_DOW_VAL%
::ECHO Days until Sunday    = %_SUN_DOW_VAL%

SET /A _SAT_DOW_VAL=6-%_DOW_VAL%
::ECHO Days until Saturday  = %_SAT_DOW_VAL%

SET /A _FRI_DOW_VAL=5-%_DOW_VAL%
::ECHO Days until Friday    = %_FRI_DOW_VAL%

SET /A _THU_DOW_VAL=4-%_DOW_VAL%
::ECHO Days until Thursday  = %_THU_DOW_VAL%

SET /A _WED_DOW_VAL=3-%_DOW_VAL%
::ECHO Days until Wednesday = %_WED_DOW_VAL%

SET /A _TUE_DOW_VAL=2-%_DOW_VAL%
::ECHO Days until Tuesday   = %_TUE_DOW_VAL%

SET /A _MON_DOW_VAL=1-%_DOW_VAL%
::ECHO Days until Monday    = %_MON_DOW_VAL%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Begin PowerShell calls

ECHO:
ECHO Getting Monday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_MON_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_MON_LONG_DATE=%%G"
::ECHO Monday date    = %_MON_LONG_DATE%
:: https://ss64.com/nt/syntax-substring.html
:: Skip 5 characters and then extract everything else
SET "_MON_DATE=%_MON_LONG_DATE:~5%"
:: https://ss64.com/nt/syntax-replace.html
:: Replace the character string '-' with '/'
SET "_MON_DATE=%_MON_DATE:-=/%"
::ECHO Monday date    = %_MON_DATE%

ECHO Getting Tuesday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_TUE_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_TUE_LONG_DATE=%%G"
::ECHO Tuesday date   = %_TUE_LONG_DATE%
SET "_TUE_DATE=%_TUE_LONG_DATE:~5%"
SET "_TUE_DATE=%_TUE_DATE:-=/%"
::ECHO Tuesday date   = %_TUE_DATE%

ECHO Getting Wednesday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_WED_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_WED_LONG_DATE=%%G"
::ECHO Wednesday date = %_WED_LONG_DATE%
SET "_WED_DATE=%_WED_LONG_DATE:~5%"
SET "_WED_DATE=%_WED_DATE:-=/%"
::ECHO Wednesday date = %_WED_DATE%

ECHO Getting Thursday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_THU_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_THU_LONG_DATE=%%G"
::ECHO Thursday date  = %_THU_LONG_DATE%
SET "_THU_DATE=%_THU_LONG_DATE:~5%"
SET "_THU_DATE=%_THU_DATE:-=/%"
::ECHO Thursday date  = %_THU_DATE%

ECHO Getting Friday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_FRI_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_FRI_LONG_DATE=%%G"
::ECHO Friday date    = %_FRI_LONG_DATE%
SET "_FRI_DATE=%_FRI_LONG_DATE:~5%"
SET "_FRI_DATE=%_FRI_DATE:-=/%"
::ECHO Friday date    = %_FRI_DATE%

ECHO Getting Saturday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_SAT_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_SAT_LONG_DATE=%%G"
::ECHO Saturday date  = %_SAT_LONG_DATE%
SET "_SAT_DATE=%_SAT_LONG_DATE:~5%"
SET "_SAT_DATE=%_SAT_DATE:-=/%"
::ECHO Saturday date  = %_SAT_DATE%

ECHO Getting Sunday's date...
FOR /F "delims=" %%G IN ('powershell -NoProfile -Command (Get-Date^).AddDays(%_SUN_DOW_VAL%^).ToString(\"yyyy-MM-dd\"^)') DO SET "_SUN_LONG_DATE=%%G"
::ECHO Sunday date    = %_SUN_LONG_DATE%
SET "_SUN_DATE=%_SUN_LONG_DATE:~5%"
SET "_SUN_DATE=%_SUN_DATE:-=/%"
::ECHO Sunday date    = %_SUN_DATE%

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Blank out DoW counts so that days that haven't happened yet are blank
SET "_MON_COUNT= "
SET "_TUE_COUNT= "
SET "_WED_COUNT= "
SET "_THU_COUNT= "
SET "_FRI_COUNT= "
SET "_SAT_COUNT= "
SET "_SUN_COUNT= "

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


:: -------------------------------------------------------------------------------
:: -------------------------------------------------------------------------------

:Refresh
SET "_CURRENT_TIME=%TIME%"
::SET "_CURRENT_TIME=21-31-09" & REM Test time: " 9:31:09 PM"
::SET "_CURRENT_TIME=02-18-56" & REM Test time: " 2:18:56 AM"

SET "_CURRENT_DATE=%DATE%"
::SET "_CURRENT_DATE=Fri 04/06/2018"
::SET "_CURRENT_DATE=Sat 04/07/2018"

CALL :ConvertTimeToSeconds "%_CURRENT_TIME%"
SET "_CURRENT_TIME_SECS=%_TIME_SECONDS%"

::SET /A "_TIME_DIFF=%_CURRENT_TIME_SECS%-%_START_TIME_SECS%"

IF NOT "%_START_DATE%"=="%_CURRENT_DATE%" (
	REM ECHO Next day^!
	REM PAUSE
	SET /A "_TIME_DIFF=86400-%_START_TIME_SECS%"
	SET /A "_TIME_DIFF+=%_CURRENT_TIME_SECS%"
) ELSE (
	SET /A "_TIME_DIFF=%_CURRENT_TIME_SECS%-%_START_TIME_SECS%"
)

::SET /A "_TIME_DIFF+=3600" & REM +60 mins
::SET /A "_TIME_DIFF+=4200" & REM +70 mins (1 hr 10 mins)
::SET /A "_TIME_DIFF+=36000" & REM +10 hrs
::SET /A "_TIME_DIFF+=36600" & REM +10 hrs 10 mins
::SET /A "_TIME_DIFF+=86400" & REM +24 hrs
::SET /A "_TIME_DIFF+=360000" & REM +100 hrs

CALL :ConvertSecondsToTime "%_TIME_DIFF%"

SET _SENT_TODAY=0
FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
	IF %%G==%_SORTABLE_DATE% (
		SET /A _SENT_TODAY+=1
	)
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Show Weekly Data
::
IF "%_SHOW_WEEKLY%"=="NARP" (
	GOTO DisplayMain
)

REM Count # of sent documents for each Day-of-the-Week

IF %_MON_DOW_VAL% LEQ 0 (
	IF %_MON_DOW_VAL% EQU 0 (
		SET "_MON_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Monday
	) ELSE (
		REM ECHO Monday has passed
		SET "_MON_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_MON_LONG_DATE% (
				SET /A _MON_COUNT+=1
			)
		)
	)
)

IF %_TUE_DOW_VAL% LEQ 0 (
	IF %_TUE_DOW_VAL% EQU 0 (
		SET "_TUE_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Tuesday
	) ELSE (
		REM ECHO Tuesday has passed
		SET "_TUE_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_TUE_LONG_DATE% (
				SET /A _TUE_COUNT+=1
			)
		)
	)
)

IF %_WED_DOW_VAL% LEQ 0 (
	IF %_WED_DOW_VAL% EQU 0 (
		SET "_WED_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Wednesday
	) ELSE (
		REM ECHO Wednesday has passed
		SET "_WED_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_WED_LONG_DATE% (
				SET /A _WED_COUNT+=1
			)
		)
	)
)

IF %_THU_DOW_VAL% LEQ 0 (
	IF %_THU_DOW_VAL% EQU 0 (
		SET "_THU_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Thursday
	) ELSE (
		REM ECHO Thursday has passed
		SET "_THU_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_THU_LONG_DATE% (
				SET /A _THU_COUNT+=1
			)
		)
	)
)

IF %_FRI_DOW_VAL% LEQ 0 (
	IF %_FRI_DOW_VAL% EQU 0 (
		SET "_FRI_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Friday
	) ELSE (
		REM ECHO Friday has passed
		SET "_FRI_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_FRI_LONG_DATE% (
				SET /A _FRI_COUNT+=1
			)
		)
	)
)

IF %_SAT_DOW_VAL% LEQ 0 (
	IF %_SAT_DOW_VAL% EQU 0 (
		SET "_SAT_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Saturday
	) ELSE (
		REM ECHO Saturday has passed
		SET "_SAT_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_SAT_LONG_DATE% (
				SET /A _SAT_COUNT+=1
			)
		)
	)
)

IF %_SUN_DOW_VAL% LEQ 0 (
	IF %_SUN_DOW_VAL% EQU 0 (
		SET "_SUN_COUNT=%_SENT_TODAY%"
		REM ECHO Today is Sunday
	) ELSE (
		REM ECHO Sunday has passed
		SET "_SUN_COUNT=0"
		FOR /F "usebackq delims=, " %%G IN ("%_CSV_PATH%") DO (
			IF %%G==%_SUN_LONG_DATE% (
				SET /A _SUN_COUNT+=1
			)
		)
	)
)

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
::
:: /End Show Weekly Data

ECHO:
::PAUSE
ECHO:

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: ===============================================================================
:: -------------------------------------------------------------------------------

:DisplayMain
CLS
::ECHO -------------------------------------------------------------------------------
::ECHO Track-SentHistory.bat--------------------------------------------Fri 04/06/2018
::ECHO ---------------------                                            --------------
::ECHO %~nx0                                            %_CURRENT_DATE%
ECHO %~nx0                                            %_START_DATE%
ECHO ^|=============================================================================^|
ECHO ^|                                                                             ^|
ECHO ^| Sent today: %_SENT_TODAY%                                                               ^|
ECHO ^|                                                                             ^|
ECHO ^|=============================================================================^|
ECHO Start time: %_START_TIME_FORMATTED%                                            %_TIME_DURATION%
::ECHO Start time:-           -------------------------------------------            -
::ECHO Start time:------------                                           -------------
::ECHO -------------------------------------------------------------------------------
::ECHO -------------------------------------------------------------------------------
ECHO:

:: Show Weekly Data
::
IF "%_SHOW_WEEKLY%"=="YARP" (
REM ECHO ^|     1    ^|     2    ^|     3    ^|     4     ^|     5    ^|     6    ^|     7    ^|
REM ECHO ^|     %_MON_TODAY%    ^|     %_TUE_TODAY%    ^|     %_WED_TODAY%    ^|     %_THU_TODAY%     ^|     %_FRI_TODAY%    ^|     %_SAT_TODAY%    ^|     %_SUN_TODAY%    ^|
ECHO       %_MON_TODAY%          %_TUE_TODAY%          %_WED_TODAY%          %_THU_TODAY%           %_FRI_TODAY%          %_SAT_TODAY%          %_SUN_TODAY%     
REM ECHO ^|==========^|==========^|==========^|===========^|==========^|==========^|==========^|
ECHO ^|=============================================================================^|
ECHO ^|   Mon.   ^|   Tues.  ^|   Wed.   ^|   Thurs.  ^|   Fri.   ^|   Sat.   ^|   Sun.   ^|
ECHO ^|==========^|==========^|==========^|===========^|==========^|==========^|==========^|
ECHO ^|   %_MON_DATE%  ^|   %_TUE_DATE%  ^|   %_WED_DATE%  ^|   %_THU_DATE%   ^|   %_FRI_DATE%  ^|   %_SAT_DATE%  ^|   %_SUN_DATE%  ^|
ECHO ^|----------^|----------^|----------^|-----------^|----------^|----------^|----------^|
ECHO ^|     %_MON_COUNT%    ^|     %_TUE_COUNT%    ^|     %_WED_COUNT%    ^|     %_THU_COUNT%     ^|     %_FRI_COUNT%    ^|     %_SAT_COUNT%    ^|     %_SUN_COUNT%    ^|
REM ECHO ^|----------^|----------^|----------^|-----------^|----------^|----------^|----------^|
ECHO ^|-----------------------------------------------------------------------------^|
ECHO:
)
::
:: /Show Weekly Data


:: Refresh data - If any resumes have been sent today, show them here after Refresh command
::
IF /I %_SENT_TODAY% GTR 0 (
ECHO:
REM Date applied:,Fancy Date:,Company:,Position:,Attachment:,URL:
REM ECHO -------------------------------------------------------------------------------
REM ECHO   Time:      | Company, Position:                                             |
REM ECHO -------------|----------------------------------------------------------------|
ECHO   Time:      ^| Company, Position:                                             ^|
ECHO -------------^|----------------------------------------------------------------^|
REM ECHO -------------------------------------------------------------------------------
REM Bugfix: cannot use :: for comments within IF statement, instead use REM
)
FOR /F "usebackq tokens=1-4 delims=," %%G IN ("%_CSV_PATH%") DO (
	SET "_FIRST_T=%%G"
	CALL SET "_EXTRACT_DATE=%%_FIRST_T:~0,10%%"
	REM ECHO "!_EXTRACT_DATE!"
	IF /I "!_EXTRACT_DATE!"=="%_SORTABLE_DATE%" (
		SET "_FANCY_DATE=%%H"
		CALL SET "_EXTRACT_TIME=%%_FANCY_DATE:~14%%"
		ECHO !_EXTRACT_TIME! ^| %%I, %%J
	)
)
::
:: /End Refresh data

ECHO:
ECHO:
:: https://ss64.com/nt/choice.html
CHOICE /C RSE /N /M "|  R - Refresh  |  S - Show/Hide Weekly Stats  |  ----  |  ----  |  E - Exit  |"
IF ERRORLEVEL 3 GOTO End
IF ERRORLEVEL 2 GOTO InitWholeWeekFunc
IF ERRORLEVEL 1 GOTO Refresh
ECHO(
ECHO ERROR: Invalid choice / Choice not recognized.
ECHO(
PAUSE
GOTO Refresh

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: End Main

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

REM ECHO DEBUGGING: Begin DefineFunctions block.

:DefineFunctions
:: Declare Functions

::Index of functions: 
:: 1. :GetDate
:: 2. :ConvertTimeToSeconds
:: 3. :ConvertSecondsToTime

GOTO SkipFunctions
:-------------------------------------------------------------------------------
:GetDate
:: Get an alphabetically sortable date, returned in a var, in yyyy-mm-dd format.
:: For convienence also get a path returned of "C:\Home Path\this script_yyyy-mm-dd.log" in a var
:: Outputs:
:: "%_SORTABLE_DATE%" (will always be exactly 10 characters long) e.g. 2018-01-28
:: "%_SORTABLE_TIME%" (will always be exactly 8 characters long) e.g. 21-31-39 or 01-57-25
:: "%_FORMATTED_TIME%" (will always be exactly 11 characters long) e.g. " 9:31:39 PM"
:: "%_SORTABLE_DATE_PATH%"
:: "%_SORTABLE_DATETIME_PATH%"
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
:: If 24hr time 'hours' is 00, change it to 12 (12:00 AM)
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
