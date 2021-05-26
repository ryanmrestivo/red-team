:: Stolen from: http://ss64.com/nt/syntax-datemath.html

@ECHO off
SETLOCAL
:: DateMath, a general purpose date math routine
   
:: If DateMath detects an error, variable _dd_int is set to 999999.
SET v_dd_int=0
SET v_mm_int=0 
SET v_yy_int=0
SET v_ymd_str=
SET v_mm_str=
SET v_dd_str=
   
IF "%3"=="" goto s_syntax
IF "%4"=="+" goto s_validate_year
IF "%4"=="-" goto s_validate_year
IF "%4"=="" goto s_validate_year
   
:s_syntax
echo.
echo DATEMATH SYNTAX:
echo _______________
echo.
echo DateMath will set the variables as listed below
echo 'str' variables include leading zeros e.g. "01"
echo 'int' variables leading zeros are stripped e.g. "1"
echo.
echo CALL DateMath YY MM DD - YY2 MM2 DD2 
echo.
echo Will set variable _dd_int to the signed difference
echo between the 2 dates (measured in days)
echo.
echo.
echo CALL DateMath YY MM DD +/- Days 
echo.
echo Will set the following variables to the result of 
echo adding or substracting days from the initial date:
echo    _ymd_str, _yy_int
echo    _mm_str, _mm_int,
echo    _dd_str, _dd_int
echo.
echo.
echo ___________________________________
pause

echo.
echo.
echo CALL DateMath YY MM DD
echo.
echo Will set the following variables:
echo    _ymd_str, _yy_int
echo    _mm_str, _mm_int,
echo    _dd_str, _dd_int
echo.
echo ___________________________________
echo.
echo _ymd_str is in YYYYMMDD format.
echo.
echo _yy_int is in YYYY format, even if YY format was originally supplied.
echo This conversion is useful for FAT/NTFS file dates which are in YY format.
echo.

ENDLOCAL & SET /a _dd_int=999999
goto :eof

:s_validate_year
::strip leading zeros
SET v_yy=%1
if %v_yy:~0,1% EQU 0 set v_yy=%v_yy:~1%

:: Check for Y2K
IF %v_yy% LSS 100 IF %v_yy% GEQ 80 SET /A v_yy += 1900
IF %v_yy% LSS 80 SET /A v_yy += 2000
   
:: at this point v_yy contains a 4 digit year

::validate month and day
if %2 GTR 12 goto s_syntax
if %3 GTR 31 goto s_syntax

SET v_mm=%2
SET v_dd=%3

::strip leading zeros
if %v_mm:~0,1% EQU 0 set v_mm=%v_mm:~1%
if %v_dd:~0,1% EQU 0 set v_dd=%v_dd:~1%

:: Set the int variables
SET /a v_dd_int=%v_dd%
SET /a v_yy_int=%v_yy%
SET /a v_mm_int=%v_mm%

:: Determine which function to perform - ADD, SUBTRACT or CONVERT

If not "%6"=="" goto s_validate_2nd_date 
if "%4"=="" goto s_convert_only

:: Add or subtract  days to a date
SET /a v_number_of_days=%5
goto s_add_or_subtract_days

:s_convert_only

SET /a v_dd_int=%v_dd%
IF %v_dd% LEQ 9 (SET v_dd_str=0%v_dd%) ELSE (SET v_dd_str=%v_dd%)
IF %v_mm% LEQ 9 (SET v_mm_str=0%v_mm%) ELSE (SET v_mm_str=%v_mm%)
SET v_ymd_str=%v_yy%%v_mm_str%%v_dd_str%

ECHO DATEMATH - Convert date only (no maths)
goto s_end
::::::::::::::::::::::::::::::::::::::::::::::::::
   
:s_validate_2nd_date
If "%4"=="+" goto s_syntax
:: Subtracting one date from another ::::::
:: strip leading zero
SET v_yy2=%5
if %v_yy2:~0,1% EQU 0 set v_yy2=%v_yy2:~1%

if %v_yy2% GTR 99 goto s_validate2nd_month
if %v_yy2% GTR 49 goto s_prefix_2_1950_1999
if %v_yy2% LSS 10 goto s_prefix_2_2000_2009
SET v_yy2=20%v_yy2%
goto s_validate2nd_month

:s_prefix_2_2000_2009
SET v_yy2=200%v_yy2%
goto s_validate2nd_month

:s_prefix_2_1950_1999
SET v_yy2=19%v_yy2%

:s_validate2nd_month
::strip leading zeros
::SET /a v_yy2=%v_yy2%
if %v_yy2:~0,1% EQU 0 set v_yy2=%v_yy2:~1%
::v_yy2 now contains a 4 digit year

if %6 GTR 12 goto s_syntax
SET v_mm2=%6

if %7 GTR 31 goto s_syntax
SET v_dd2=%7

::strip leading zeros
::SET /a v_mm2=%v_mm2%
if %v_mm2:~0,1% EQU 0 set v_mm2=%v_mm2:~1%
::SET /a v_dd2=%v_dd2%
if %v_dd2:~0,1% EQU 0 set v_dd2=%v_dd2:~1%

call :s_julian_day %v_yy_int% %v_mm_int% %v_dd_int%
SET v_sumdays1=%v_JulianDay%

call :s_julian_day %v_yy2% %v_mm2% %v_dd2%
SET v_sumdays2=%v_JulianDay%
  
SET /a v_dd_int=%v_sumdays1% - %v_sumdays2%
   
ECHO DATEMATH - Subtracting one date from another = days difference
ECHO ~~~~~~
ECHO %v_dd_int%
ECHO ~~~~~~
goto s_end_days
::::::::::::::::::::::::::::::::::::::::::::::::::
   
:s_add_or_subtract_days
if /i "%4"=="+" goto s_add_up_days

:: Subtract all days ::::::
SET /a v_dd=%v_dd% - %v_number_of_days%
   
:s_adjust_month_year
if %v_dd% GEQ 1 goto s_add_subtract_days_DONE
SET /a v_mm=%v_mm% - 1
if %v_mm% GEQ 1 goto s_add_days_%v_mm%
SET /a v_yy=%v_yy% - 1
SET /a v_mm=%v_mm% + 12
goto s_add_days_%v_mm%
   
:s_add_days_2
SET /a v_dd=%v_dd% + 28
SET /a v_leapyear=%v_yy% / 4
SET /a v_leapyear=%v_leapyear% * 4
if %v_leapyear% NEQ %v_yy% goto s_adjust_month_year
SET /a v_dd=%v_dd% + 1
goto s_adjust_month_year
    
:s_add_days_4
:s_add_days_6
:s_add_days_9
:s_add_days_11
SET /a v_dd=%v_dd% + 30
goto s_adjust_month_year

:s_add_days_1
:s_add_days_3
:s_add_days_5
:s_add_days_7
:s_add_days_8
:s_add_days_10
:s_add_days_12
SET /a v_dd=%v_dd% + 31
goto s_adjust_month_year
 
:s_add_up_days
:: add all days ::::::
SET /a v_dd=%v_dd% + %v_number_of_days%
   
:s_subtract_days_
goto s_subtract_days_%v_mm%
     
:s_adjust_mth_yr
SET /a v_mm=%v_mm% + 1
if %v_mm% LEQ 12 goto s_subtract_days_%v_mm%
SET /a v_yy=%v_yy% + 1
SET /a v_mm=%v_mm% - 12
goto s_subtract_days_%v_mm%

:s_subtract_days_2
SET /a v_leapyear=%v_yy% / 4
SET /a v_leapyear=%v_leapyear% * 4
If %v_leapyear% EQU %v_yy% goto s_subtract_leapyear

if %v_dd% LEQ 28 goto s_add_subtract_days_DONE
SET /a v_dd=%v_dd% - 28
goto s_adjust_mth_yr
   
:s_subtract_leapyear
if %v_dd% LEQ 29 goto s_add_subtract_days_DONE
SET /a v_dd=%v_dd% - 29
goto s_adjust_mth_yr
   
:s_subtract_days_4
:s_subtract_days_6
:s_subtract_days_9
:s_subtract_days_11
if %v_dd% LEQ 30 goto s_add_subtract_days_DONE
SET /a v_dd=%v_dd% - 30
goto s_adjust_mth_yr

:s_subtract_days_1
:s_subtract_days_3
:s_subtract_days_5
:s_subtract_days_7
:s_subtract_days_8
:s_subtract_days_10
:s_subtract_days_12
if %v_dd% LEQ 31 goto s_add_subtract_days_DONE
SET /a v_dd=%v_dd% - 31
goto s_adjust_mth_yr
   
:s_add_subtract_days_DONE
SET /a v_dd_int=%v_dd%
SET /a v_mm_int=%v_mm%
SET /a v_yy_int=%v_yy%
IF %v_dd% GTR 9 (SET v_dd_str=%v_dd%) ELSE (SET v_dd_str=0%v_dd%)
IF %v_mm% GTR 9 (SET v_mm_str=%v_mm%) ELSE (SET v_mm_str=0%v_mm%)
SET v_ymd_str=%v_yy%%v_mm_str%%v_dd_str%
   
ECHO DATEMATH - add or subtract days from a date = new date
goto s_end
::::::::::::::::::::::::::::::::::::::::::::::::::

:s_julian_day
SET v_year=%1
SET v_month=%2
SET v_day=%3
   
SET /a v_month=v_month
SET /a v_day=v_day
  
SET /A a = 14 - v_month
SET /A a /= 12
SET /A y = v_year + 4800 - a
SET /A m = v_month + 12 * a - 3
SET /A m = 153 * m + 2
SET /A m /= 5
SET /A v_JulianDay = v_day + m + 365 * y + y / 4 - y / 100 + y / 400 - 32045
   
ECHO The Julian Day is [%v_JulianDay%]
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::
   
:s_end
ECHO ~~~~~~~~~~~~
ECHO [%v_ymd_str%] YY=[%v_yy_int%] MM=[%v_mm_str%] DD=[%v_dd_str%]
ECHO ~~~~~~~~~~~~
:s_end_days
ENDLOCAL&SET /a _yy_int=%v_yy_int%&SET /a _mm_int=%v_mm_int%&SET /a _dd_int=%v_dd_int%&SET _ymd_str=%v_ymd_str%&SET _mm_str=%v_mm_str%&SET _dd_str=%v_dd_str%

