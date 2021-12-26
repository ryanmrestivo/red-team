#!/bin/bash

#Author Github:   https://github.com/g666gle
#Author Twitter:  https://twitter.com/g666gle1
#Date: 1/29/2019
#Usage: N/A <Helper File for Query>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

if [ "${PWD##*/}" == "BaseQuery" ];then
	# Grab everything before the @ sign
	user_name=$(echo "$1" | cut -d @ -f 1 | awk '{print tolower($0)}')
	email=$(echo "$1" | cut -d : -f 1 | awk '{print tolower($0)}')
	#  Check to make sure the user name is at least 4 and the email has a @
	if [ ${#user_name} -ge 4 ] && [[ $email == *"@"* ]];then
		# Grab each individual character
		first_char=${user_name:0:1}  # {variable name: starting position : how many letters}
		second_char=${user_name:1:1}
		third_char=${user_name:2:1}
		fourth_char=${user_name:3:1}
		
		#  Check the first directory
		if [ -d ./data/"$first_char" ];then
			#  Check the second directory
			if [ -d  ./data/"$first_char"/"$second_char" ];then
				#  Check the third directory
				if [ -d ./data/"$first_char"/"$second_char"/"$third_char" ];then
					printf "${GREEN}Email Address: $email${NC}\n"
					#  Check to see if the file exists
					if [ -e ./data/"$first_char"/"$second_char"/"$third_char"/"$fourth_char".txt ];then
						#  Open the file and search for the email address then only keep the passwords, iterate through the passwords and echo then
						cat ./data/"$first_char"/"$second_char"/"$third_char"/"$fourth_char".txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
							printf "Password: ${RED}$Password${NC}\n"
						done
						
						#  Check to see if the email is in the NOT VALID file
						if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
							cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
								printf "Password: ${RED}$Password${NC}\n"
							done	
						fi
					else
						printf "${GREEN}Email Address: $email${NC}\n"
						#  The file does not exists
						#  Check to make sure the directory exists and the file exists for 0UTLIERS
						if [[ -d ./data/$first_char/$second_char/$third_char/0UTLIERS && -e ./data/$first_char/$second_char/$third_char/0UTLIERS/0utliers.txt ]];then
							cat ./data/"$first_char"/"$second_char"/"$third_char"/0UTLIERS/0utliers.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
								printf "Password: ${RED}$Password${NC}\n"
							done	
						fi

						#  Check to see if the email is in the NOT VALID file
						if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
							cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
								printf "Password: ${RED}$Password${NC}\n"
							done	
						fi					
					fi
				else
					printf "${GREEN}Email Address: $email${NC}\n"
					#  The third letter directory does not exists
					if [[ -d ./data/$first_char/$second_char/0UTLIERS && -e ./data/$first_char/$second_char/0UTLIERS/0utliers.txt ]];then
						cat ./data/"$first_char"/"$second_char"/0UTLIERS/0utliers.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
							printf "Password: ${RED}$Password${NC}\n"
						done	
					fi

					#  Check to see if the email is in the NOT VALID file
					if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
						cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
							printf "Password: ${RED}$Password${NC}\n"
						done	
					fi
				fi
			else
				printf "${GREEN}Email Address: $email${NC}\n"
				#  The second letter directory does not exists
				if [[ -d ./data/$first_char/0UTLIERS && -e ./data/$first_char/0UTLIERS/0utliers.txt ]];then
					cat ./data/"$first_char"/0UTLIERS/0utliers.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
						printf "Password: ${RED}$Password${NC}\n"
					done	
				fi

				#  Check to see if the email is in the NOT VALID file
				if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
					cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
						printf "Password: ${RED}$Password${NC}\n"
					done	
				fi
			fi
		else
			printf "${GREEN}Email Address: $email${NC}\n"
			#  The first letter directory does not exists
			if [[ -d ./data/0UTLIERS && -e ./data/0UTLIERS/0utliers.txt ]];then
				cat ./data/0UTLIERS/0utliers.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
					printf "Password: ${RED}$Password${NC}\n"
				done	
			fi

			#  Check to see if the email is in the NOT VALID file
			if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
				cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "$email" | cut -d : -f 2- | while read -r Password;do
					printf "Password: ${RED}$Password${NC}\n"
				done	
			fi
		fi
	else
		printf "${GREEN}Email Address: $email${NC}\n"
		if [[ $email == *"@"* ]];then
			#  The username is either not >= 4 or the email doesn't contain an @
			#  Check to see if the email is in the NOT VALID file
			if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
				cat ./data/NOTVALID/FAILED_TEST.txt | grep -i "^$email" | cut -d : -f 2- | while read -r Password;do
					printf "Password: ${RED}$Password${NC}\n"
				done	
			fi
		else
			printf "${YELLOW}[!]${NC} Please enter one email address or a file with one email address per line\n"
		fi
	fi

else
	printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
fi
