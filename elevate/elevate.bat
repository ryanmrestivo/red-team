@Echo Off

REM Executes a command in an elevated PowerShell window and captures/displays output
REM Note that any file paths must be fully qualified!

REM Example: elevate myAdminCommand -myArg1 -myArg2 someValue

if "%1"=="" (
	REM If no command is passed, simply open an elevated PowerShell window.
	PowerShell -Command "& {Start-Process PowerShell.exe -Wait -Verb RunAs}"
) ELSE (
	REM Copy command+arguments (passed as a parameter) into a ps1 file
	REM Start PowerShell with Elevated access (prompting UAC confirmation)
	REM 	and run the ps1 file
	REM 	then close elevated window when finished
	REM Output captured results

	IF EXIST %temp%\trans.txt del %temp%\trans.txt
	Echo %* ^> %temp%\trans.txt *^>^&1 > %temp%\tmp.ps1
	Echo $error[0] ^| Add-Content %temp%\trans.txt -Encoding Default >> %temp%\tmp.ps1
	PowerShell -Command "& {Start-Process PowerShell.exe -Wait -ArgumentList '-ExecutionPolicy Bypass -File ""%temp%\tmp.ps1""' -Verb RunAs}"
	Type %temp%\trans.txt
)