#!/bin/bash
#   /$$$$$$                                /$$                 /$$$$$$$$ /$$   /$$ /$$$$$$$$
#  /$$__  $$                              | $$                | $$_____/| $$  / $$| $$_____/
# | $$  \__/ /$$$$$$$   /$$$$$$   /$$$$$$ | $$   /$$ /$$   /$$| $$      |  $$/ $$/| $$
# |  $$$$$$ | $$__  $$ /$$__  $$ |____  $$| $$  /$$/| $$  | $$| $$$$$    \  $$$$/ | $$$$$
#  \____  $$| $$  \ $$| $$$$$$$$  /$$$$$$$| $$$$$$/ | $$  | $$| $$__/     >$$  $$ | $$__/
#  /$$  \ $$| $$  | $$| $$_____/ /$$__  $$| $$_  $$ | $$  | $$| $$       /$$/\  $$| $$
# |  $$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$$| $$ \  $$|  $$$$$$$| $$$$$$$$| $$  \ $$| $$$$$$$$
#  \______/ |__/  |__/ \_______/ \_______/|__/  \__/ \____  $$|________/|__/  |__/|________/
#                                                    /$$  | $$
#                                                   |  $$$$$$/
#                                                    \______/
RandomCode=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 30 ; echo '') # lenght of 30
Directory="/usr/SneakyEXE"
AddNULL=0
RealPath=$(
	cd $(dirname "$0")
	pwd
)
Lib="${RealPath}/Linux/LibEXE"       # Directory
Script="${RealPath}/Linux/sneakyexe" # Script
PathRoot="/etc/profile.d/sneakyExe"
Shfile="${PathRoot}.sh"
Var=0
while [ -d $Directory ]
	do
		Var=1 
		Directory="${Directory}_"
	done
if [ $Var -ne 0 ]
	then
		Directory=${Directory%?}
	else
		Directory=${Directory}
fi
if [ -f "${Directory}/sneakyexe" ] && [ -d "${Directory}/LibEXE" ] && [ -f "${Directory}/LibEXE/Errno.py" ] && [ -f "${Directory}/LibEXE/functions.py" ] && [ -f "${Directory}/LibEXE/Installed.txt" ] && [ -f "${Directory}/LibEXE/log.err" ] && [ -f "${Directory}/LibEXE/payload.init" ] && [ -d "${Directory}/LibEXE/__pycache__" ] && [ -f "${Directory}/LibEXE/__pycache__/Errno.cpython-36.pyc" ] && [ -f "${Directory}/LibEXE/__pycache__/functions.cpython-36.pyc" ]
	then
		printf "(\x1B[31m*\x1B[0m) SneakyEXE - Already installed\n"
		exit 6
	else
		cat /etc/shadow > /dev/null 2>&1
fi
if [ $? -ne 0 ]
	then
		printf "(\x1B[31m*\x1B[0m) SneakyEXE - Permission denied, please recheck\n"
		exit 3
	else
		printf "+ Checking for Python3..."
fi
function CheckingInternet(){ # Checking internet connection
	ping -c 1 python.org > /dev/null 2>&1
	if [ $? -eq 0 ]
		then
			printf ""
		else
			printf " [\x1B[31mX\x1B[0m]\n"
			printf " - \x1B[31mError\x1B[0m - Unable to connect to the internet\n"
			exit 2
	fi
}
if hash "python3" 2>/dev/null; then # Checking Python3
	printf " [\x1B[32mOK\x1B[0m]\n"
	printf "+ Checking for Pip..."
else
	printf " [\x1B[31mX\x1B[0m]\n"
	printf " - \x1B[31mError\x1B[0m - Python3 isn't installed, please do so before proceeding\n"
	exit 1
fi
if hash "pip3" 2>/dev/null; then # Checking pip3
	printf " [\x1B[32mOK\x1B[0m]\n"
	printf "+ Installing Pillow library..."
else
	printf " [\x1B[31mX\x1B[0m]\n"
	printf " - \x1B[31mError\x1B[0m - pip3 isn't installed, please do so before proceeding\n"
	exit 1
fi
python3 -c "import PIL" 2> /dev/null # Checking Pillow
if [ $? -eq 0 ]
	then
		printf " [\x1B[32mOK\x1B[0m]\n"
		printf "+ Installing termcolor module..."
	else
		CheckingInternet
		printf " [\x1B[32mOK\x1B[0m]\n"
		printf "+ Installing termcolor module..."
		pip3 install Pillow > /dev/null 2>&1

fi
python3 -c "import termcolor" 2> /dev/null # Checking termcolor v
if [ $? -eq 0 ]
	then
		printf " [\x1B[32mOK\x1B[0m]\n"
		printf "+ Initializing directory..."
	else
		CheckingInternet
		pip3 install termcolor > /dev/null 2>&1
		printf " [\x1B[32mOK\x1B[0m]\n"
		printf "+ Initializing directory..."
fi
mkdir $Directory
printf " [\x1B[32mOK\x1B[0m]\n"
printf "+ Duplicating project's files...\n"
cp -rf $Lib $Directory
printf "  => LibEXE ( module )\n"
cp $Script $Directory
chmod 755 "${Directory}"
chmod 755 "${Directory}/LibEXE"
chmod 755 "${Directory}/sneakyexe"
chmod 755 "${Directory}/LibEXE/Errno.py"
chmod 755 "${Directory}/LibEXE/functions.py"
chmod 755 "${Directory}/LibEXE/Installed.txt"
chmod 755 "${Directory}/LibEXE/log.err"
chmod 755 "${Directory}/LibEXE/payload.init"
printf "  => sneakyexe ( Script )\n"
printf " - Status - \x1B[32mOK\x1B[0m\n"
# Adding to $PATH
while [ -f Shfile ]
	do
		PathRoot="${PathRoot}_"
		Shfile="${PathRoot}.sh"
	done
echo "PATH=${Directory}:\$PATH" > $Shfile
echo $Shfile > "${Directory}/profile.d"
chmod 744 "${Directory}/profile.d"
echo 1 > "${Directory}/LibEXE/Installed.txt"
chmod +x "${Directory}/sneakyexe"
printf "(\x1B[32m*\x1B[0m) : Installation completed, you might wanna reboot the system or re-login\n"
printf " - Reboot/Logout/Abort ? [r/l/a]:"
read REPLY
while [ "$REPLY" != "r" ] && [ "$REPLY" != "l" ] && [ "$REPLY" != "a" ]
	do
		printf " - Invalid answer, try again ? [r/l/a]:"
		read REPLY
	done
if [ "$REPLY" == "r" ];then
	reboot
elif [ "$REPLY" == "l" ];then
	pkill -u $USER
else
	printf " - ABORTED -\n"
	exit 9
fi
