@echo off
color a
set /p SRoot="XAMPP Root Drive = "
echo.
echo Compiling the build...
ModEncrypt\ModEncrypt.exe Bot\Plague.exe %SRoot%:\xampp\htdocs\modules\Build.mod Return > nul
echo Copying files...
xcopy /S /E /Y "D:\xampp\htdocs\*" "Server" > nul
echo Cleaning up...
del /S /Q Server\dashboard\*.* > nul
rmdir /S /Q Server\dashboard > nul
del /Q Server\logs\*.* > nul
rem del /Q Server\uploads\*.* > nul
rmdir Server\webalizer > nul
del /S /Q Server\xampp\*.* > nul
rmdir Server\xampp > nul
del /Q Server\applications.html > nul
del /Q Server\favicon.ico > nul
del /Q Server\bitnami.css > nul
del /Q Server\index_old.php > nul
del /Q Builder\Builder.ini > nul
echo Setting up empty directories...
copy /Y NUL Server\logs\.gitignore >NUL
rem copy /Y NUL Server\uploads\.gitignore >NUL
echo.
echo Done.
echo.