#!/bin/bash
#
# information gathering script for use on the OSCP
# It was designed to enumerate fast while gathering as much information as possible then outputs to html and opens firefox.
#
# Note: It will only do a TCP scan, if you want a UDP scan, run the other scaner.
# 
# It requires manually inputting the target IP address/es in /root/user/iplist.txt


  # Colours
  ESC="\e["
  RESET=$ESC"39m"
  RED=$ESC"31m"
  GREEN=$ESC"32m"
  BLUE=$ESC"34m"
  YELLOW=$ESC"33m"

function enumeration_scan {
  echo ""
  echo "               w----------------------------------------------------------------w"
  echo "               |                                                                |"
  echo "               |                  Information Gathering                         |"
  echo "               |                                                                |"
  echo "               w----------------------------------------------------------------w"
  echo ""
}

function next_host {
  printf "\n"
  printf "*************************************************"
  printf "       ${GREEN}Starting next host!${RESET}       "
  printf "*************************************************"
  printf "\n"
}

  enumeration_scan

# do a nmap tcp all ports scan and run searchsploit on the results

function tcp_all_ports {
  echo ""
  echo "            *********************************************************************"
  echo "            |                                                                   |"
  echo "            |               Now starting a TCP all ports scan!                  |"
  echo "            |                                                                   |"
  echo "            *********************************************************************"
  echo ""
}

  tcp_all_ports

# Identify all tcp ports running on the ip addresses in the list.

for ip in $(cat /root/user/iplist.txt); do
mkdir -p /root/user/hosts/$ip/nmap_scans/

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}TCP all ports nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -sV -Pn -T4 -p- -oX /root/user/hosts/$ip/nmap_scans/allports-scan.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/allports-scan.xml \
  -o /root/user/hosts/$ip/nmap_scans/allports-scan-report.html
  sleep 2;

  /usr/bin/firefox &
  firefox /root/user/hosts/$ip/nmap_scans/allports-scan-report.html

  next_host
done

# do a detailed nmap scan over all tcp ports

  echo ""
  echo "                 ************************************************************************"
  echo "                 |                                                                       |"
  echo "                 |               Now starting detailed all ports TCP scan!               |"
  echo "                 |                       This may take a while...                        |"
  echo "                 |                                                                       |"
  echo "                 ************************************************************************"
  echo ""

for ip in $(cat /root/user/iplist.txt); do

printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Detailed TCP nmap scan for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -sV -sC -Pn --reason --version-all -T4 -p- -A -oX /root/user/hosts/$ip/nmap_scans/detailed-scan.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/detailed-scan.xml \
  -o /root/user/hosts/$ip/nmap_scans/detailed-scan-report.html


  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE}Now running searchsploit over results...${RESET}\n"
  printf "**Please advise this is not 100 percent and manual testings are preferred, due to nmap output**\n"
  printf "\n"
  sleep 2;
  searchsploit -v --nmap /root/user/hosts/$ip/nmap_scans/detailed-scan.xml >> /root/user/hosts/$ip/nmap_scans/detailed_searchsploit-results.xml
  cat /root/user/hosts/$ip/nmap_scans/detailed_searchsploit-results.xml

  printf "\n"
  firefox /root/user/hosts/$ip/nmap_scans/detailed-scan-report.html
  sleep 5;

  next_host
done

  echo ""
  echo "                *****************************************************************"
  echo "                |                                                               |"
  echo "                |                Now starting the Nmap NSE scan!                |"
  echo "                |                                                               |"
  echo "                *****************************************************************"
  echo ""

# Run a NSE Scan for all IP addresses in iplist.txt and output to firefox

for ip in $(cat /root/user/iplist.txt); do

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap FTP NSE scan over port 21 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -Pn -p 21 --script=ftp-anon,ftp-bounce,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221 \
  -oX /root/user/hosts/$ip/nmap_scans/ftp_port21.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/ftp_port21.xml \
  -o /root/user/hosts/$ip/nmap_scans/ftp_port21_report_$ip.html
  sleep 2;

# I havent added nmap nse script for port 22
# This will usually just be for brute forcing the host

printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMTP NSE scan over port 25 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -p 25 --script=smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720,smtp-vuln-cve2011-1764 \
  -oX /root/user/hosts/$ip/nmap_scans/smtp_nse.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/smtp_nse.xml \
  -o /root/user/hosts/$ip/nmap_scans/smtp_nse_report.html
  sleep 2;2

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTP NSE scan over port 80 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -Pn -p 80,8080,8000 --script=http-auth-finder,http-comments-displayer,http-config-backup,http-method-tamper,http-passwd,http-default-accounts,http-robots.txt,http-enum,http-exif-spider,http-fileupload-exploiter,http-php-version,http-sql-injection,http-userdir-enum \
  -oX /root/user/hosts/$ip/nmap_scans/http_port80.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/http_port80.xml \
  -o /root/user/hosts/$ip/nmap_scans/http_port80_report.html
  sleep 2;

# not scanning for pop3
# not running pop3-brute in this scan

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap NFS NSE scan over port 111 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -Pn -p 111 --script=nfs-ls,nfs-showmount,nfs-statfs \
  -oX /root/user/hosts/$ip/nmap_scans/nfs_port111.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/nfs_port111.xml \
  -o /root/user/hosts/$ip/nmap_scans/nfs_port111_report.html
  sleep 2;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -Pn -vv -p 139,445 --script=smb-enum-domains,smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-enum-groups,smb-enum-processes,smb-server-stats,smb-system-info,smbv2-enabled \
  -oX /root/user/hosts/$ip/nmap_scans/smb_nse.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/smb_nse.xml \
  -o /root/user/hosts/$ip/nmap_scans/smb_nse_report.html
  sleep 2;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SMB_Vulns NSE scan over port 139 and 445 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -p 139,445 --script-args=unsafe=1 --script=smb-vuln-conficker,smb-vuln-cve2009-3103,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-regsvc-dos \
  -oX /root/user/hosts/$ip/nmap_scans/smb_nse_vuln.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/smb_nse_vuln.xml \
  -o /root/user/hosts/$ip/nmap_scans/smb_nse_vuln_report.html
  sleep 2;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap SNMP NSE scan over port 161 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -p 161 --script=snmp-info,snmp-netstat,snmp-processes,snmp-sysdescr,snmp-win32-services,snmp-win32-shares,snmp-win32-software,snmp-win32-users \
  -oX /root/user/hosts/$ip/nmap_scans/snmp_nse.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/snmp_nse.xml \
  -o /root/user/hosts/$ip/nmap_scans/snmp_nse_report.html
  sleep 2;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap HTTPS NSE scan over port 443 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -p 443 --script-args vulns.showall --script=ssl-heartbleed,ssl-poodle,ssl-dh-params \
  -oX /root/user/hosts/$ip/nmap_scans/https_nse.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/https_nse.xml \
  -o /root/user/hosts/$ip/nmap_scans/https_nse_report.html
  sleep 2;

  printf "\n"
  printf "${RED}[+]${RESET} ${BLUE} Nmap MySQL NSE scan over port 3306 for $ip...${RESET}\n"
  printf "\n"
  nmap -vv -p 445,1433,3306 --script=ms-sql-info,mysql-audit,mysql-databases,mysql-dump-hashes,mysql-empty-password,mysql-enum,mysql-info,mysql-query,mysql-users,mysql-variables,mysql-vuln-cve2012-2122 \
  -oX /root/user/hosts/$ip/nmap_scans/mysql_nse.xml $ip && xsltproc /root/user/hosts/$ip/nmap_scans/mysql_nse.xml \
  -o /root/user/hosts/$ip/nmap_scans/mysql_nse_report.html
  sleep 2;

printf "Now to output all NSE scans for $ip to firefox!\n"
    firefox /root/user/hosts/$ip/nmap_scans/ftp_port21_report_$ip.html
    firefox /root/user/hosts/$ip/nmap_scans/http_port80_report.html
    sleep 2;
    firefox /root/user/hosts/$ip/nmap_scans/nfs_port111_report.html
    firefox /root/user/hosts/$ip/nmap_scans/smb_nse_report.html
    firefox /root/user/hosts/$ip/nmap_scans/smb_nse_vuln_report.html
    sleep 2;
    firefox /root/user/hosts/$ip/nmap_scans/snmp_nse_report.html
    firefox /root/user/hosts/$ip/nmap_scans/https_nse_report.html
    firefox /root/user/hosts/$ip/nmap_scans/mysql_nse_report.html
    sleep 2;
done

printf "${RED}[+]${RESET} Scans completed\n"
printf "${RED}[+]${RESET} Results saved to /root/user/nmap_scans/'IP_ADDRESS'\n"
printf "${RED}[+]${RESET} For more port information, follow: 0daySecurity Enumeration\n"

exit