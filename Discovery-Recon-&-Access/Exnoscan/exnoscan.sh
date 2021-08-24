##! /bin/sh

# ExnoScan
# Author: Securethelogs.com

echo '

    __                                      
   /__\_  ___ __   ___  ___  ___ __ _ _ __  
  /_\ \ \/ / |_ \ / _ \/ __|/ __/ _` | |_ \ 
 //__  >  <| | | | (_) \__ \ (_| (_| | | | |
 \__/ /_/\_\_| |_|\___/|___/\___\__,_|_| |_|

 @Securethelogs

 Bash Script to run automated scans'

echo -e " \e[31mPlease ensure you have permission before scanning..."

sleep 4

echo -e "\033[1;34m [*] Checking if files already exists..."

echo ""

# checking for installed file ...

FILE=./scan/installed.txt
if test -f "$FILE"; then
	echo "$FILE exists, skipping to run...."
else

# if not; make files ...

mkdir scan
mkdir sublist
mkdir nmap
mkdir results
mkdir dirs
mkdir harvest

touch ./scan/domains.txt
touch ./scan/iplist.txt
touch ./scan/scanlist.txt
touch ./scan/installed.txt
touch ./scan/urls.txt

git clone https://github.com/aboul3la/Sublist3r.git
git clone https://github.com/laconicwolf/Nmap-Scan-to-CSV.git
git clone https://github.com/maurosoria/dirsearch.git


fi

# Check if domains present ...

if [ -s /scan/domains.txt ]
then
	echo -e " \e[31m [*] ./scan/domains empty, please fill in before running... "

else 


echo ""
echo -e "\033[1;34m [*] Domains present, starting Recon....."

rm scan/scanlist.txt -f
rm sublist/scanlist.txt -f 


# subdomain enumeration

while read p; do
	   python3 ./Sublist3r/sublist3r.py -d $p -o ./sublist/subscan.txt
       cat ./sublist/subscan.txt >> ./sublist/scanlist.txt	

done <./scan/domains.txt


echo -e "\033[1;34m [*] Completed subdomain enumeration."
echo -e "\033[1;34m [*] Moving onto scanning URLs..."

rm ./dirs/webhost.txt -f
rm ./dirs/nc.txt -f 

cat ./scan/urls.txt >> ./sublist/scanlist.txt


# using netcat to test if website up

while read p; do
	nc -zv -w 1 $p 443 &> /dev/null && echo $p >> ./dirs/nc.txt || nc -zv -w 1 $p 80 &> /dev/null && echo $p >> ./dirs/nc.txt || echo "$p Offline"
	sort ./dirs/nc.txt | uniq > ./dirs/webhost.txt
done <./sublist/scanlist.txt

# dirsearch 

while read p; do
	python3 ./dirsearch/dirsearch.py -u $p -e php,txt,asp,aspx,js --plain-text-report ./dirs/tempdir.txt 
	cat ./dirs/tempdir.txt >> ./dirs/dirsearch.txt
done <./dirs/webhost.txt


# adding IPs for later scan
cat ./scan/iplist.txt >> ./sublist/scanlist.txt

rm ./nmap/scanlist.txt -f
sort ./sublist/scanlist.txt | uniq >> ./nmap/scanlist.txt


echo -e "\033[1;34m [*] Starting Nmap..." 

rm ./nmap/results.xml -f

nmap -Pn -T4 -sV -p 21,22,53,80,135,139,443,445,465,389,993,995,3389,8443,8080,9000 -iL ./nmap/scanlist.txt -oX ./nmap/results.xml


echo -e "\033[1;34m [*] Converting results to CSV..."

D=$(date +%Y-%m-%d)
mkdir results/$D
OUT=./results/$D/scan_$D.csv

python3 ./Nmap-Scan-to-CSV/nmap_xml_parser.py -f ./nmap/results.xml -csv $OUT


# If harvester installed, run 

if ! command -v theharvester &> /dev/null
then
    echo "TheHarvester not installed, skipping email enumeration ..."
else

# The Harvester

echo -e "\033[1;34m [*] Enumerating email addresses..." 

while read p; do
	   theharvester -d $p -l 500 -b google,bing -f ./harvest/scan.xml
	   cat ./harvest/scan.xml >> ./harvest/harvest.xml

done <./scan/domains.txt

#move harvester

cat ./harvest/harvest.xml | grep -Eo "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | sort -u >> ./results/$D/emailsfound.txt

fi


# move dirsearch

cat ./dirs/dirsearch.txt | grep 200 | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u >> ./results/$D/dirsearch.txt


# move sublist

cp ./sublist/scanlist.txt ./results/$D/subdomains.txt


# zipp it all

zip -rm ./results/$D.zip ./results/$D/


# End ...

fi


