#!/bin/bash

#Author Github:   https://github.com/g666gle
#Author Twitter:  https://twitter.com/g666gle1
#Date: 1/29/2019
#Usage: ./query test@example.com

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

#  Checks to see if the user forgot to enter input
if [ $# -eq 1 ];then
	if [ "${PWD##*/}" == "BaseQuery" ];then
		if ! [ -e "$1" ];then
			./search.sh "$1"
		else
			# A file was inputed
			cat "$1" | while read -r email;do
				echo
				./search.sh "$email"
			done
		fi
	else
		printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
	fi
else
	printf "${YELLOW}[!]${NC} Please enter one email address or a file with one email address per line\n"
fi
