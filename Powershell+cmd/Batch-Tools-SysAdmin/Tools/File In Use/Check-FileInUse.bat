@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion

:RunAsAdministrator
:: SS64 Run with elevated permissions script (ElevateMe.vbs)
:: Thanks to: http://ss64.com/vb/syntax-elevate.html
:-------------------------------------------------------------------------------
:: First check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 GOTO START

GOTO START & REM <-- Leave this line in to always skip Elevation Prompt -->
:: <-- Remove this block to always RunAs Administrator -->
ECHO:
ECHO CHOICE Loading...
ECHO:
:: https://ss64.com/nt/choice.html
CHOICE /M "Run as Administrator?"
IF ERRORLEVEL 2 GOTO START & REM No.
IF ERRORLEVEL 1 REM Yes.
:: <-- Remove this block to always RunAs Administrator -->

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

:Header
CLS
ECHO:
ECHO Script name ^( %~nx0 ^) & REM This script's file name and extension. https://ss64.com/nt/syntax-args.html
ECHO Working directory: %~dp0 & REM The drive letter and path of this script's location.
ECHO Current directory: %CD% & REM The path of the currently selected directory.
REM Bugfix: cannot use :: for comments within IF statement, instead use REM
ECHO:
:: Check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >nul
IF %ERRORLEVEL% EQU 0 (
	ECHO Elevated Permissions: YES
) ELSE ( 
	ECHO Elevated Permissions: NO
)
ECHO:
ECHO Input parameters [%1] [%2] [%3] ...
ECHO:
::PAUSE
CLS

REM -------------------------------------------------------------------------------

:Parameters

:: Param1 = File Path

::SET "_FILE_PATH=C:\Users\G\Documents\SpiderOak Hive\RottenEggs\Decision-Making Tools"
::SET "_FILE_PATH=C:\Users\G\Documents\SpiderOak Hive\RottenEggs\Decision-Making Tools\T-Chart_Template.docx"
::SET "_FILE_PATH=C:\Users\G\Documents\SpiderOak Hive\RottenEggs\Decision-Making Tools\T-Chart_Double_Template.docx"
SET "_FILE_PATH=D:\VirtualBox VMs\RE-Pipsqueak_default_1540100072761_449"

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM -------------------------------------------------------------------------------

:ExternalFunctions
:: Load External functions:

::Banner.cmd
:-------------------------------------------------------------------------------
SET "_ORIG_DIR=%CD%
::CD ..
SET "_BANNER_FUNC=%CD%\Banner\Banner.cmd"
::CD %_ORIG_DIR%

IF NOT EXIST "%_BANNER_FUNC%" (
	SET "_BANNER_FUNC=%CD%\Banner.cmd"
)

::SET "_BANNER_FUNC=%USERPROFILE%\Documents\__\Banner\Banner.cmd"
IF NOT EXIST "%_BANNER_FUNC%" (
	SET "_BANNER_FUNC=%USERPROFILE%\Documents\SpiderOak Hive\Programming\Batch\+Function Library\Banner\Banner.cmd"
)

IF NOT EXIST "%_BANNER_FUNC%" (
	ECHO:
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find Banner.cmd
	ECHO %_BANNER_FUNC%
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
)
::- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:: Script name & extention
FOR %%G IN ("%_BANNER_FUNC%") DO SET "_BANNER_FUNC_NAME=%%~nxG"

:: Script drive & path
FOR %%G IN ("%_BANNER_FUNC%") DO SET "_BANNER_FUNC_PATH=%%~dpG"
:-------------------------------------------------------------------------------

::Handle.exe
:-------------------------------------------------------------------------------
SET "_PACKAGE_NAME=sysinternals"
SET "_HANDLE_EXE=%ChocolateyInstall%\lib\%_PACKAGE_NAME%\tools\handle.exe"
SET "_HANDLE_EXE64=%ChocolateyInstall%\lib\%_PACKAGE_NAME%\tools\handle64.exe"

IF NOT EXIST "%_HANDLE_EXE64%" (
	SET "_HANDLE_EXE64=%_HANDLE_EXE%"
)

IF NOT EXIST "%_HANDLE_EXE%" (
	ECHO:
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find Handle.exe
	ECHO %_HANDLE_EXE%
	ECHO:
	ECHO Please make sure SysInternals is installed via Chocolatey.
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
)
:: handle.exe /?
:: "%_HANDLE_EXE%" /?
:-------------------------------------------------------------------------------

::ProcExp.exe
:-------------------------------------------------------------------------------
SET "_PACKAGE_NAME=sysinternals"
SET "_PROCEXP_EXE=%ChocolateyInstall%\lib\%_PACKAGE_NAME%\tools\procexp.exe"
SET "_PROCEXP_EXE64=%ChocolateyInstall%\lib\%_PACKAGE_NAME%\tools\procexp64.exe"

IF NOT EXIST "%_PROCEXP_EXE64%" (
	SET "_PROCEXP_EXE64=%_PROCEXP_EXE%"
)

IF NOT EXIST "%_PROCEXP_EXE%" (
	ECHO:
	ECHO -------------------------------------------------------------------------------
	ECHO ERROR: Cannot find ProcExp.exe
	ECHO %_PROCEXP_EXE%
	ECHO:
	ECHO Please make sure SysInternals is installed via Chocolatey.
	ECHO -------------------------------------------------------------------------------
	ECHO:
	PAUSE
	ECHO:
	REM GOTO END
)
:: procexp.exe /?
:: "%_PROCEXP_EXE%" /?
:-------------------------------------------------------------------------------

::End ExternalFunctions

REM -------------------------------------------------------------------------------
REM ===============================================================================
REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
:Main
CLS

CALL :SampleFunction
PAUSE

:: Banner.cmd Compatible characters:
:: 0-9
:: Hyphen "-"
:: Period "."
:: A-Z (Caps only)
:: Space " "

:: Banner.cmd maximum string length is 14.
:: 12345678901234
:: File-in-use
::  File-in-use

::CALL "%_BANNER_FUNC%" Hello World
SET "_PROGRAM_NAME=  File-in-use"
::ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
CALL "%_BANNER_FUNC%" "%_PROGRAM_NAME%"
ECHO # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
::ECHO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECHO:
ECHO Check which processes are locking a file. Requires SysInternals to be installed
ECHO:
ECHO Selected Path:
ECHO %_FILE_PATH%
ECHO:
::ECHO CHOICE Loading...
:: https://ss64.com/nt/choice.html
CHOICE /M "Use selected path?"
IF ERRORLEVEL 2 GOTO EnterPath & REM No.
IF ERRORLEVEL 1 GOTO EndEnterPath & REM Yes.

:EnterPath
ECHO:
::SET /P "_FILE_PATH=Enter file path:"
                   ::-------------------------------------------------------------------------------
::SET /P "_FILE_PATH=Enter file path:----------------------------------------------------------------"
:: Plus 1 character to normal HR string, because this time we actually want it to create a newline
SET /P "_FILE_PATH=Enter file path:                                                                "
:EndEnterPath

GOTO SkipHelp
ECHO:
ECHO Help:
::"%_HANDLE_EXE%" /?
"%_HANDLE_EXE64%" /?
ECHO:
PAUSE
:SkipHelp

GOTO SkipDump
ECHO:
ECHO Standard Dump ^(no switches^):
::"%_HANDLE_EXE%"
"%_HANDLE_EXE64%"
ECHO:
PAUSE
:SkipDump

ECHO:
ECHO Processing . . .
ECHO:
::"%_HANDLE_EXE%" |findstr /i "%_FILE_PATH%"
::"%_HANDLE_EXE64%" |findstr /i "%_FILE_PATH%"
"%_HANDLE_EXE64%" "%_FILE_PATH%" -nobanner
ECHO:
ECHO Finished.
ECHO:

::ECHO CHOICE Loading...
:: https://ss64.com/nt/choice.html
CHOICE /M "Run again?"
IF ERRORLEVEL 2 GOTO END & REM No.
IF ERRORLEVEL 1 GOTO Main & REM Yes.


REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REM ===============================================================================
REM -------------------------------------------------------------------------------

:: <-- Footer could also go here -->

GOTO SkipFunctions
:: Declare Functions
:DefineFunctions
:-------------------------------------------------------------------------------
:SampleFunction RequiredParam [OptionalParam]
:: Dependences: other functions this one is dependent on.
:: Description for SampleFunction's purpose & ability.
:: Description of RequiredParam and OptionalParam.
:: Outputs:
:: "%_SAMPLE_OUTPUT_1%"
:: "%_SAMPLE_OUTPUT_2%"
@ECHO OFF
::SETLOCAL
SETLOCAL EnableDelayedExpansion
SET "_required_param=%1"
SET "_optional_param=%2"
:: Also works: IF [%1]==[] (
IF [!_required_param!]==[] (
	REM ECHO ERROR in SampleFunction^! No Required Parameter.
	REM ECHO:
	REM PAUSE
	REM ENDLOCAL
	REM EXIT /B
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

ECHO:

REM                     ___                                          ___
REM  __________________/  /                       __________________/  /
REM | _    _______    /  /                       | _    _______    /  /
REM |(_) .d########b. //)| _____________________ |(_) .d########b. //)|
REM |  .d############//  ||        _____        ||  .d############//  |
REM | .d######""####//b. ||() ||  [JAY C]  || ()|| .d######""####//b. |
REM | 9######(  )#_//##P ||()|__|  | = |  |__|()|| 9######(  )#_//##P |
REM | 'b######++#/_/##d' ||() ||   | = |   || ()|| 'b######++#/_/##d' |
REM |  "9############P"  ||   ||   |___|   ||   ||  "9############P"  |
REM |  _"9a#######aP"    ||  _   _____..__   _  ||  _"9a#######aP"    |
REM | |_|  `""""''       || (_) |_____||__| (_) || |_|  `""""''       |
REM |  ___..___________  ||_____________________||  ___..___________  |
REM | |___||___________| |                       | |___||___________| |
REM |____________________|Remove YOUR BRA 2 email|____________________|

ECHO                     ___                                          ___
ECHO  __________________/  /                       __________________/  /
ECHO ^| _    _______    /  /                       ^| _    _______    /  /
ECHO ^|(_) .d########b. //)^| _____________________ ^|(_) .d########b. //)^|
ECHO ^|  .d############//  ^|^|        _____        ^|^|  .d############//  ^|
ECHO ^| .d######""####//b. ^|^|() ^|^|  [JAY C]  ^|^| ()^|^| .d######""####//b. ^|
ECHO ^| 9######(  )#_//##P ^|^|()^|__^|  ^| = ^|  ^|__^|()^|^| 9######(  )#_//##P ^|
ECHO ^| 'b######++#/_/##d' ^|^|() ^|^|   ^| = ^|   ^|^| ()^|^| 'b######++#/_/##d' ^|
ECHO ^|  "9############P"  ^|^|   ^|^|   ^|___^|   ^|^|   ^|^|  "9############P"  ^|
ECHO ^|  _"9a#######aP"    ^|^|  _   _____..__   _  ^|^|  _"9a#######aP"    ^|
ECHO ^| ^|_^|  `""""''       ^|^| (_) ^|_____^|^|__^| (_) ^|^| ^|_^|  `""""''       ^|
ECHO ^|  ___..___________  ^|^|_____________________^|^|  ___..___________  ^|
ECHO ^| ^|___^|^|___________^| ^|                       ^| ^|___^|^|___________^| ^|
ECHO ^|____________________^|Remove YOUR BRA 2 email^|____________________^|

ECHO:
PAUSE
ECHO:

REM  ___________________________________________
REM |  _______________________________________  |
REM | / .-----------------------------------. \ |
REM | | | /\ :                        90 min| | |
REM | | |/--\:....................... NR [ ]| | |
REM | | `-----------------------------------' | |
REM | |      //-\\   |         |   //-\\      | |
REM | |     ||( )||  |_________|  ||( )||     | |
REM | |      \\-//   :....:....:   \\-//      | |
REM | |       _ _ ._  _ _ .__|_ _.._  _       | |
REM | |      (_(_)| |(_(/_|  |_(_||_)(/_      | |
REM | |               low noise   |           | |
REM | `______ ____________________ ____ ______' |
REM |        /    []             []    \        |
REM |       /  ()                   ()  \       |
REM !______/_____________________________\______!
REM Simon Williams

ECHO  ___________________________________________
ECHO ^|  _______________________________________  ^|
ECHO ^| / .-----------------------------------. \ ^|
ECHO ^| ^| ^| /\ :                        90 min^| ^| ^|
ECHO ^| ^| ^|/--\:....................... NR [ ]^| ^| ^|
ECHO ^| ^| `-----------------------------------' ^| ^|
ECHO ^| ^|      //-\\   ^|         ^|   //-\\      ^| ^|
ECHO ^| ^|     ^|^|( )^|^|  ^|_________^|  ^|^|( )^|^|     ^| ^|
ECHO ^| ^|      \\-//   :....:....:   \\-//      ^| ^|
ECHO ^| ^|       _ _ ._  _ _ .__^|_ _.._  _       ^| ^|
ECHO ^| ^|      (_(_)^| ^|(_(/_^|  ^|_(_^|^|_)(/_      ^| ^|
ECHO ^| ^|               low noise   ^|           ^| ^|
ECHO ^| `______ ____________________ ____ ______' ^|
ECHO ^|        /    []             []    \        ^|
ECHO ^|       /  ()                   ()  \       ^|
ECHO ^^!______/_____________________________\______^^!
REM Simon Williams

ECHO:
PAUSE
ECHO:

REM                                       /|
REM                                      |\|
REM                                      |||
REM                                      |||
REM                                      |||
REM                                      |||
REM                                      |||
REM                                      |||
REM                                   ~-[{o}]-~
REM                                      |/|
REM                                      |/|
REM              ///~`     |\\_          `0'         =\\\\         . .
REM             ,  |='  ,))\_| ~-_                    _)  \      _/_/|
REM            / ,' ,;((((((    ~ \                  `~~~\-~-_ /~ (_/\
REM          /' -~/~)))))))'\_   _/'                      \_  /'  D   |
REM         (       (((((( ~-/ ~-/                          ~-;  /    \--_
REM          ~~--|   ))''    ')  `                            `~~\_    \   )
REM              :        (_  ~\           ,                    /~~-     ./
REM               \        \_   )--__  /(_/)                   |    )    )|
REM     ___       |_     \__/~-__    ~~   ,'      /,_;,   __--(   _/      |
REM   //~~\`\    /' ~~~----|     ~~~~~~~~'        \-  ((~~    __-~        |
REM ((()   `\`\_(_     _-~~-\                      ``~~ ~~~~~~   \_      /
REM  )))     ~----'   /      \                                   )       )
REM   (         ;`~--'        :                                _-    ,;;(
REM             |    `\       |                             _-~    ,;;;;)
REM             |    /'`\     ;                          _-~          _/
REM            /~   /    |    )                         /;;;''  ,;;:-~
REM           |    /     / | /                         |;;'   ,''
REM           /   /     |  \\|                         |   ,;(    -Tua Xiong
REM         _/  /'       \  \_)                   .---__\_    \,--._______
REM        ( )|'         (~-_|                   (;;'  ;;;~~~/' `;;|  `;;;\
REM         ) `\_         |-_;;--__               ~~~----__/'    /'_______/
REM         `----'       (   `~--_ ~~~;;------------~~~~~ ;;;'_/'
REM                      `~~~~~~~~'~~~-----....___;;;____---~~

ECHO                                       /^|
ECHO                                      ^|\^|
ECHO                                      ^|^|^|
ECHO                                      ^|^|^|
ECHO                                      ^|^|^|
ECHO                                      ^|^|^|
ECHO                                      ^|^|^|
ECHO                                      ^|^|^|
ECHO                                   ~-[{o}]-~
ECHO                                      ^|/^|
ECHO                                      ^|/^|
ECHO              ///~`     ^|\\_          `0'         =\\\\         . .
ECHO             ,  ^|='  ,))\_^| ~-_                    _)  \      _/_/^|
ECHO            / ,' ,;((((((    ~ \                  `~~~\-~-_ /~ (_/\
ECHO          /' -~/~)))))))'\_   _/'                      \_  /'  D   ^|
ECHO         (       (((((( ~-/ ~-/                          ~-;  /    \--_
ECHO          ~~--^|   ))''    ')  `                            `~~\_    \   )
ECHO              :        (_  ~\           ,                    /~~-     ./
ECHO               \        \_   )--__  /(_/)                   ^|    )    )^|
ECHO     ___       ^|_     \__/~-__    ~~   ,'      /,_;,   __--(   _/      ^|
ECHO   //~~\`\    /' ~~~----^|     ~~~~~~~~'        \-  ((~~    __-~        ^|
ECHO ((()   `\`\_(_     _-~~-\                      ``~~ ~~~~~~   \_      /
ECHO  )))     ~----'   /      \                                   )       )
ECHO   (         ;`~--'        :                                _-    ,;;(
ECHO             ^|    `\       ^|                             _-~    ,;;;;)
ECHO             ^|    /'`\     ;                          _-~          _/
ECHO            /~   /    ^|    )                         /;;;''  ,;;:-~
ECHO           ^|    /     / ^| /                         ^|;;'   ,''
ECHO           /   /     ^|  \\^|                         ^|   ,;(   & REM -Tua Xiong
ECHO         _/  /'       \  \_)                   .---__\_    \,--._______
ECHO        ( )^|'         (~-_^|                   (;;'  ;;;~~~/' `;;^|  `;;;\
ECHO         ) `\_         ^|-_;;--__               ~~~----__/'    /'_______/
ECHO         `----'       (   `~--_ ~~~;;------------~~~~~ ;;;'_/'
ECHO                      `~~~~~~~~'~~~-----....___;;;____---~~


ECHO:
PAUSE
ECHO:

REM               ...                            
REM              ;::::;                           
REM            ;::::; :;                          
REM          ;:::::'   :;                         
REM         ;:::::;     ;.                        
REM        ,:::::'       ;           OOO\         
REM        ::::::;       ;          OOOOO\        
REM        ;:::::;       ;         OOOOOOOO       
REM       ,;::::::;     ;'         / OOOOOOO      
REM     ;:::::::::`. ,,,;.        /  / DOOOOOO    
REM   .';:::::::::::::::::;,     /  /     DOOOO   
REM  ,::::::;::::::;;;;::::;,   /  /        DOOO  
REM ;`::::::`'::::::;;;::::: ,#/  /          DOOO 
REM :`:::::::`;::::::;;::: ;::#  /            DOOO
REM ::`:::::::`;:::::::: ;::::# /              DOO
REM `:`:::::::`;:::::: ;::::::#/               DOO
REM  :::`:::::::`;; ;:::::::::##                OO
REM  ::::`:::::::`;::::::::;:::#                OO
REM  `:::::`::::::::::::;'`:;::#                O 
REM   `:::::`::::::::;' /  / `:#                  
REM    ::::::`:::::;'  /  /   `#        
::-------------------------------------------------------------------------------

ECHO  ##    #     # #   ####     ##  #   # #### ###         # #     #   #  #
ECHO #     # #   # # #  #       #  #  # #  #    #  #       # # #   # #  ## #
ECHO # ##  ###   # # #  ###     #  #  # #  ###  ###        # # #   ###  # ##
ECHO  ##  #   # #     # ####     ##    #   #### #  # #    #     # #   # #  #
ECHO               ...                              #
ECHO              ;::::;                           
ECHO            ;::::; :;                          
ECHO          ;:::::'   :;                         
ECHO         ;:::::;     ;.                        
ECHO        ,:::::'       ;           OOO\         
ECHO        ::::::;       ;          OOOOO\        
ECHO        ;:::::;       ;         OOOOOOOO       
ECHO       ,;::::::;     ;'         / OOOOOOO      
ECHO     ;:::::::::`. ,,,;.        /  / DOOOOOO    
ECHO   .';:::::::::::::::::;,     /  /     DOOOO   
ECHO  ,::::::;::::::;;;;::::;,   /  /        DOOO  
ECHO ;`::::::`'::::::;;;::::: ,#/  /          DOOO 
ECHO :`:::::::`;::::::;;::: ;::#  /            DOOO
ECHO ::`:::::::`;:::::::: ;::::# /              DOO
ECHO `:`:::::::`;:::::: ;::::::#/               DOO
ECHO  :::`:::::::`;; ;:::::::::##                OO
ECHO  ::::`:::::::`;::::::::;:::#                OO
ECHO  `:::::`::::::::::::;'`:;::#                O 
ECHO   `:::::`::::::::;' /  / `:#                  
ECHO    ::::::`:::::;'  /  /   `#        

REM ^(waiting 5 seconds^)
PING -n 6 127.0.0.1 > nul

CALL "%_BANNER_FUNC%" H@Ked, son

ECHO:
PAUSE
ECHO:

REM             *********
REM            *************
REM           *****     *****
REM          ***           ***
REM         ***             ***
REM         **    0     0    **
REM         **               **                  ____
REM         ***             ***             //////////
REM         ****           ****        ///////////////  
REM         *****         *****    ///////////////////
REM         ******       ******/////////         |  |
REM       *********     ****//////               |  |
REM    *************   **/////*****              |  |
REM   *************** **///***********          *|  |*
REM  ************************************    ****| <=>*
REM *********************************************|<===>* 
REM *********************************************| <==>*
REM ***************************** ***************| <=>*
REM ******************************* *************|  |*
REM ********************************** **********|  |*  Matthew Kott  
REM *********************************** *********|  |


ECHO             *********
ECHO            *************
ECHO           *****     *****
ECHO          ***           ***
ECHO         ***             ***
ECHO         **    0     0    **
ECHO         **               **                  ____
ECHO         ***             ***             //////////
ECHO         ****           ****        ///////////////  
ECHO         *****         *****    ///////////////////
ECHO         ******       ******/////////         ^|  ^|
ECHO       *********     ****//////               ^|  ^|
ECHO    *************   **/////*****              ^|  ^|
ECHO   *************** **///***********          *^|  ^|*
ECHO  ************************************    ****^| ^<=^>*
ECHO *********************************************^|^<===^>* 
ECHO *********************************************^| ^<==^>*
ECHO ***************************** ***************^| ^<=^>*
ECHO ******************************* *************^|  ^|*
ECHO ********************************** **********^|  ^|*  & REM Matthew Kott  
ECHO *********************************** *********^|  ^|

:: https://www.asciiart.eu/mythology/grim-reapers


ECHO:
PAUSE
ECHO:

ECHO:
PAUSE
ECHO:


:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SET "_result=%_required_param%"

:: - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ENDLOCAL & SET "_SAMPLE_OUTPUT_1=%_result%" & SET "_SAMPLE_OUTPUT_2=%_use_optional%"
EXIT /B
:-------------------------------------------------------------------------------
:: End functions
:SkipFunctions
:END
:Footer
ENDLOCAL
ECHO: 
ECHO End %~nx0
ECHO: 
PAUSE
::GOTO:EOF
EXIT /B & REM If you call this program from the command line and want it to return to CMD instead of closing Command Prompt, need to use EXIT /B or no EXIT command at all.
