
REM ECHO DEBUGGING: Begin parameter script: %~nx0 & REM "%~dpnx0" = will return the Drive letter, Path, Name, & eXtention of this script.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param1 = File A

SET "_FILE_A=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\powershell-template (2).bat"

SET "_FILE_A=\\gammafox\C$\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template.ps1"

SET "_FILE_A=%~dpnx0" & REM "%~dpnx0" = will return the Drive letter, Path, Name, & eXtention of this script.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:: Param2 = File B

SET "_FILE_B=%UserProfile%\Documents\GitHub\Batch-Tools-SysAdmin\powershell-template (2).bat"

SET "_FILE_B=\\gammafox\C$\Users\G\Documents\SpiderOak Hive\Programming\Powershell\Templates\powershell-template (2).ps1"

SET "_FILE_B=%~dpnx0" & REM "%~dpnx0" = will return the Drive letter, Path, Name, & eXtention of this script.

REM - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM ECHO DEBUGGING: End of parameter script.
