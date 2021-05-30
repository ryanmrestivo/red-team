@Echo Off

REM Executes a command in an elevated PowerShell window then pauses

REM Example: elevatep myAdminCommand -myArg1 -myArg2 someValue

if "%1"=="" (
	REM If no command is passed, simply open an elevated PowerShell window.
	PowerShell -Command "& {Start-Process PowerShell.exe -Wait -Verb RunAs}"
) ELSE (
	REM Copy command+arguments (passed as a parameter) into a ps1 file
	REM Start PowerShell with Elevated access (prompting UAC confirmation)
	REM 	and run the ps1 file
	REM 	then pause until ENTER is pressed
	REM 	then Close elevated window when finished
	REM Output results are not captured (they are visible up to pause)

	Echo %* > %temp%\tmp.ps1
	Echo pause >> %temp%\tmp.ps1
	PowerShell -Command "& {Start-Process PowerShell.exe -Wait -ArgumentList '-ExecutionPolicy Bypass -File ""%temp%\tmp.ps1""' -Verb RunAs}"
)