#!/bin/bash
#
# information gathering script for use on the OSCP
# It was designed to enumerate fast while gathering as much information as possible then outputs to html and opens firefox.
#
# Note: It will only do a UDP scan, if you want a TCP scan, run the other scaner..
# 
# It requires manually inputting the target IP address/es in /root/user/iplist.txt
# 



function udp_all_ports {
  echo ""
  echo "            *********************************************************************"
  echo "            |                                                                   |"
  echo "            |                          UDP all ports Scanner                    |"
  echo "            |                                                                   |"
  echo "            *********************************************************************"
  echo ""
}

udp_all_ports

function next_host {
  printf "\n"
  printf "*************************************************"
  printf "       ${GREEN}Starting next host!${RESET}       "
  printf "*************************************************"
  printf "\n"
}


for ip in $(cat /root/user/iplist.txt); do
  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}UDP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -sU -vv -Pn --stats-every 3m --max-retries 2 -oX /root/user/hosts/$ip/nmap_scans/udp-scan.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/udp-scan.xml \
  -o /root/user/hosts/$ip/nmap_scans/udp-scan-report.html

  sleep 2;

  firefox /root/user/hosts/$ip/nmap_scans/udp-scan-report.html

  next_host

  done

  exit