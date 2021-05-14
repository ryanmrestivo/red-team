@Echo Off

REM Executes a command in an elevated PowerShell window and keeps window open for more work

REM Example: elevatex myAdminCommand -myArg1 -myArg2 someValue

if "%1"=="" (
	REM If no command is passed, simply open an elevated PowerShell window.
	PowerShell -Command "& {Start-Process PowerShell.exe -Wait -Verb RunAs}"
) ELSE (
	REM Copy command+arguments (passed as a parameter) into a ps1 file
	REM Start PowerShell with Elevated access (prompting UAC confirmation)
	REM 	and run the ps1 file
	REM 	but leave elevated window open when finished

	Echo %* > %temp%\tmp.ps1
	PowerShell -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoExit -ExecutionPolicy Bypass -File ""%temp%\tmp.ps1""' -Verb RunAs}"
)