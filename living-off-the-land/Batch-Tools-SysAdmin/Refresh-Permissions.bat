@ECHO OFF
:: Refresh User's Group Permissions (without-logging-off-and-back-in)
:: https://community.spiceworks.com/how_to/7562-refresh-user-s-group-membership-without-logging-off-and-on
:: Bear in mind that any other programs they already had open (excel, word etc) won't be aware of the new group memebership though. 
:: When they next launch them from the start menu, desktop, or from double clicking a file, they will be aware of the new group membership as they will then be child processes of the new explorer.exe instance and therefore will inherit the security token from it. 

::PS\> $UserCredential = Get-Credential

ECHO Type in Username: (DOMAIN\username) e.g. IQ\jdoe
SET /P Username=

::SET Username=IQ\gjames
::ECHO Username set: %Username%

::Verify password is valid before killing any processes?

TASKKILL /F /IM explorer.exe

RUNAS /user:%Username% explorer.exe

ECHO.
ECHO User permissions refreshed.
ECHO. 
ECHO If you had any applications open, those apps will have to be closed and 
ECHO restarted to have the new permissions.
ECHO.

PAUSE
