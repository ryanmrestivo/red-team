#!/bin/bash

#Author Github:   https://github.com/g666gle
#Author Twitter:  https://twitter.com/g666gle1
#Date: 1/29/2019
#Usage: ./Import

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

printf "${RED}[*]${NC} Starting at $(date)\n"
#Checks to see if the user is working out of the BaseQuery directory
if [ "${PWD##*/}" == "BaseQuery" ];then
	#  Prime the data folder
	python3 folderPrimer.py
	#  Checks to see if the Import directory is there
	if [ -d ./PutYourDataBasesHere ];then
		dataDir=$(pwd)
		#  Read each file in the input directory, in sorted order
		ls ./PutYourDataBasesHere | sort | while read -r inputfile;do
			file_SHA_sum="$(sha256sum "$dataDir"/PutYourDataBasesHere/"$inputfile" | awk '{print$1}')"
			#  check to see if the database has already been imported
			if [ "$(grep "$file_SHA_sum" -c < ./Logs/importedDBS.log)" == "0" ];then
				#  Call a python script to iterate through the file and sort them
				python3 pysort.py "$inputfile"
				printf "${YELLOW}[!] Adding $inputfile to importedDBS.log${NC}\n"
				echo "$file_SHA_sum" "$(date)" "$inputfile" >> "$dataDir"/Logs/importedDBS.log
				echo
			else
				printf "${YELLOW}[!]${NC} $inputfile SHASUM found in importedDBS.log and is already stored in the data folder\n"
			fi
		done

	else    #  If the Import directory doesn't exist
		dataDir=$(pwd)
		printf "${RED}ERROR: Please make a directory called 'PutYourDataBasesHere' in $dataDir${NC}\n"
	fi
else
	# If the users working directory is not BaseQuery while trying to run the script
	printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
fi

echo
printf "${RED}[*]${NC} Completed\n"




