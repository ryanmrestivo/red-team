#!/bin/bash

#Author Github:   https://github.com/g666gle
#Author Twitter:  https://twitter.com/g666gle1
#Date: 1/29/2019
#Usage: ./run.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

clear
echo "           _               _                  _            _               _       _                  _            _    _        _   "
echo "          / /\            / /\               / /\         /\ \            /\ \    /\_\               /\ \         /\ \ /\ \     /\_\ "
echo "         / /  \          / /  \             / /  \       /  \ \          /  \ \  / / /         _    /  \ \       /  \ \\\\ \ \   / / / "
echo "        / / /\ \        / / /\ \           / / /\ \__   / /\ \ \        / /\ \ \ \ \ \__      /\_\ / /\ \ \     / /\ \ \\\\ \ \_/ / /  "
echo "       / / /\ \ \      / / /\ \ \         / / /\ \___\ / / /\ \_\      / / /\ \ \ \ \___\    / / // / /\ \_\   / / /\ \_\\\\ \___/ /   "
echo "      / / /\ \_\ \    / / /  \ \ \        \ \ \ \/___// /_/_ \/_/     / / /  \ \_\ \__  /   / / // /_/_ \/_/  / / /_/ / / \ \ \_/    "
echo "     / / /\ \ \___\  / / /___/ /\ \        \ \ \     / /____/\       / / / _ / / / / / /   / / // /____/\    / / /__\/ /   \ \ \     "
echo "    / / /  \ \ \__/ / / /_____/ /\ \   _    \ \ \   / /\____\/      / / / /\ \/ / / / /   / / // /\____\/   / / /_____/     \ \ \    "
echo "   / / /____\_\ \  / /_________/\ \ \ /_/\__/ / /  / / /______     / / /__\ \ \/ / / /___/ / // / /______  / / /\ \ \        \ \ \   "
echo "  / / /__________\/ / /_       __\ \_\\\\ \/___/ /  / / /_______\   / / /____\ \ \/ / /____\/ // / /_______\/ / /  \ \ \        \ \_\  "
echo "  \/_____________/\_\___\     /____/_/ \_____\/   \/__________/   \/________\_\/\/_________/ \/__________/\/_/    \_\/         \/_/  "
echo 

while true;do
	echo
	echo "Options:"
	echo "		[1] Import Your data"
	echo "		[2] Calculate Import Time"
	echo "		[3] Query"
	echo "		[4] Harvest Email Addresses"
	echo "		[5] Message"
	echo "		[Q] Quit"
	echo
	read -p "Option Number-> " answer

	#  Check to see if the answer is only letters
	if [[ "$answer" =~ ^[a-zA-Z]+$ ]];then
		if [[ "$answer" == [Qq] ]];then
			clear
			exit
		fi

	#  Check to see if the answer is only numbers
	elif [[ "$answer" =~ ^[0-9]+$ ]];then
		
		if [ "$answer" -eq 1 ];then
			if [ "${PWD##*/}" == "BaseQuery" ];then
				./Import.sh
				echo
			else
				printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
			fi

		elif [ "$answer" -eq 2 ];then
			echo
			echo "Please enter the number of lines you wish to import..."
			read -p "> " num_lines
			if [[ "$num_lines" =~ ^[0-9]+$ ]];then
				#  10114 is about the number of lines processed in one second on average
				secs=$(echo "$num_lines/10114" | bc -l)
				mins=$(echo "$secs/60" | bc -l)
				hours=$(echo "$mins/60" | bc -l)
				days=$(echo "$hours/24" | bc -l)
				years=$(echo "$days/365" | bc -l)
				printf "The import time should take ABOUT %0.2f seconds which is...\n" "$secs"
				printf "                                  %0.2f minutes which is...\n" "$mins"
				printf "                                  %0.2f hours which is...\n" "$hours"
				printf "                                  %0.2f days\n" "$days"
				printf "                                  %0.2f years\n" "$years"
			else
				printf "${YELLOW}[!]${NC} Invalid input\n"
			fi
			echo

		elif [ "$answer" -eq 3 ];then
			if [ "${PWD##*/}" == "BaseQuery" ];then
				echo
				printf "Please enter an email address or the full path to a file with one email per line. \n"
				printf "			ex) test@example.com\n"
				printf "			ex) /home/user/Desktop/email_list.txt\n\n"
				read -p "> " email
				./query.sh "$email"
				echo
			else
				printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
			fi

		elif [ "$answer" -eq 4 ];then
			if [ "${PWD##*/}" == "BaseQuery" ];then
				echo
				echo "Quick Search (1) or In-depth Search (2)? (Enter 1 or 2)"
				read -p "> " preference
				if [[ "$preference" =~ ^[0-9]+$ ]];then
					if [ "$preference" -eq 1 ];then
						printf "${GREEN}Code taken from https://github.com/laramies/theHarvester${NC}\n"
						printf "${GREEN}		   Go check him out${NC}\n"
						if ! [ -d ./theHarvester ];then
							printf "${YELLOW}[!]${NC} Installing theHarvester\n"
							git clone https://github.com/laramies/theHarvester.git &> /dev/null
						fi
						printf "${YELLOW}[!]${NC} Checking requirements\n"
						python3 -m pip install -r requirements.txt &> /dev/null
						if [ "$( pip3 freeze | grep -c numpy )" -eq 0 ];then
							printf "${YELLOW}[!]${NC} Installing additional dependencies\n"
							pip3 install numpy &> /dev/null
						fi
						printf "${YELLOW}[!] PLACE ANY API KEYS IN $(pwd)/theHarvester/api-keys.yaml${NC}\n"		
						echo "Domain name? ex) google.com"
						read -p "> " domain
						echo "Limit for the amount of email addresses? ex) 500"
						read -p "> " limit
						printf "
			${RED}source:${NC} baidu, bing, bingapi, censys, crtsh, cymon,
			dogpile, duckduckgo, google, googleCSE, google-
			certificates, google-profiles, hunter, intelx,
			linkedin, netcraft, pgp, securityTrails, threatcrowd,
			trello, twitter, vhost, virustotal, yahoo, all\n"
						echo
						echo "Source? ex) all"
						read -p "> " source 
						cd ./theHarvester
						python3 ./theHarvester.py -d "$domain" -l "$limit" -b "$source"
						cd ..
						echo
						printf "${RED}COPY ONLY THE EMAIL ADDRESSES AND SAVE THEM TO A .TXT FILE${NC}\n"
						printf "${RED}YOU CAN USE THE TEXT FILE AS INPUT TO QUERY ALL OF THEM AT ONCE${NC}\n"
						echo

					elif [ "$preference" -eq 2 ];then
						printf "${YELLOW}[!]${NC} Checking if Python 2 is installed\n"
						sudo apt-get install python -y &> /dev/null
						sudo apt-get install curl -y &> /dev/null
						pip install dns.resolver &> /dev/null

						#  Checking to see if the SimplyEmail directory is already there
						if ! [ -d ./SimplyEmail ];then
							printf "${YELLOW}[!]${NC} Installing SimplyEmail\n"
							curl -s https://raw.githubusercontent.com/killswitch-GUI/SimplyEmail/master/setup/oneline-setup.sh | bash &> /dev/null
						fi

						#  Checking to see if curl and python-magic are already installed

						if [ "$( pip freeze | grep -c python-magic )" -eq 0 ];then
							printf "${YELLOW}[!]${NC} Installing additional dependencies\n"
							pip install python-magic &> /dev/null
						fi
						if [ "$( pip freeze | grep -c fake_useragent )" -eq 0 ];then
							printf "${YELLOW}[!]${NC} Installing additional dependencies\n"
							pip install fake_useragent &> /dev/null
						fi
						
						echo "Domain name? ex) google.com"
						read -p "> " domain
						cd ./SimplyEmail
						echo $(pwd)
						python SimplyEmail.py -all -v -e $domain
						echo python SimplyEmail.py -all  -e $domain
						cd ..
					fi  # Checking if answer equals 1 or 2
				fi  # Cheking if answer is numeric
			else
				printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
			fi  # Checking proper directory

		elif [ "$answer" -eq 5 ];then
			echo
			echo "Hey... thanks for downloading Base Query, I've spent way too many hours coding this"
			echo "Base Query is a great program to help you organize and query all those pesky databases you have laying around"
			echo "With a tripple nested structure and a careful design your querys should be INSTANTANEOUS! Or ya know like really fast."
			echo "Something broken? Check the logs and then message me!"
			echo "For more information regarding use check the README file"
			echo "Found a bug? Just want to talk? Message me on GitHub or Twitter https://github.com/g666gle"
			echo "					                        https://twitter.com/g666gle1"
			echo "													         V1.0"
			echo 

		fi

	fi
	read -sp "Press Enter to continue..." 
	clear
	
done
