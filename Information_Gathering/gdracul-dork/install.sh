#!/bin/bash

dracul_signature(){
echo  "|------------------------------------------------|"
echo  "|                                                |"			 
echo  "|  |  __ \|  __ \     /\   / ____| |  | | |      |"
echo  "|  | |  | | |__) |   /  \ | |    | |  | | |      |"
echo  "|  | |  | |  _  /   / /\ \| |    | |  | | |      |"
echo  "|  | |__| | | \ \  / ____ \ |____| |__| | |____  |"	
echo  "|  |_____/|_|  \_\/_/    \_\_____|\____/|______| |"
echo  "|                                                |"
echo  "|------------------------------------------------|"
echo  "|        GOOGLE DORK DRACUL INSTALL ENGINE       |"
echo  "|------------------------------------------------|"
}

clear
dracul_signature
sudo apt-get update -y
sudo apt install -y python2
sudo apt install wine64 -y
sudo apt install wine32 -y 
sudo apt install winetricks -y 
sudo apt install mono-complete -y
sudo winetricks dotnet45
sudo pip install requests
sudo pip install bs4
sudo mkdir -p /usr/share/gdracul_dork_finder
sudo cp -r * /usr/share/gdracul_dork_finder/
sudo cp -r /usr/share/gdracul_dork_finder/gdraculc /usr/local/bin/gdracul
sudo cp -r /usr/share/gdracul_dork_finder/gdracul.desktop /usr/share/applications/
clear
dracul_signature
echo " "
echo " [*] The installation process has been completed !!!"
echo " [*] An icon has been added !"
echo " [*] If you execute 'sudo gdracul -s' and it doesn't work, consider using 'gdracul -s' without sudo."
echo " [*] Execute 'gdracul -h' for some help"
echo " "
echo " [*] You are free to edit the code."
echo " [*] Dont use this for bad."
echo " [*] It was coded by [draculwhitehat] from: https://raidforums.com/ for educational purpose" 
echo " [*] Buy me a coffee: https://www.buymeacoffee.com/dracul"
echo " [*] GitHub: https://github.com/draculwhitehat/gdracul"
echo " "
sudo gdracul -s