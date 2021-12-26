#Exploit Pack - Security Framework for Exploit Developers
#Copyright 2011 Juan Sacco http://exploitpack.com
#
#This program is free software: you can redistribute it and/or modify it under the terms of the
#GNU General Public License as published by the Free Software Foundation, either version 3 
#or any later version.
#
#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#PURPOSE. See the GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License along with this program. 
#If not, see http://www.gnu.org/licenses/

import sys
import socket
import telnetlib

Host = sys.argv[1]
#ShellCodePort = sys.argv[2]

print "Exploit Pack - Remote Shellcode Console\r\n"
print "Connecting to " + Host
print "Please wait...\r\n"
print "CTRL+C to exit\r\n"

PORT = 1234              # Arbitrary non-privileged port
s = None
for res in socket.getaddrinfo(Host, PORT, socket.AF_UNSPEC,
                              socket.SOCK_STREAM, 0, socket.AI_PASSIVE):
    af, socktype, proto, canonname, sa = res
    try:
        s = socket.socket(af, socktype, proto)
    except socket.error as msg:
        s = None
        continue
    try:
        s.bind(sa)
        s.listen(1)
    except socket.error as msg:
        s.close()
        s = None
        continue
    break
if s is None:
    print 'could not open socket'
    sys.exit(1)
conn, addr = s.accept()
print 'Connected by', addr
data = conn.recv(1024)
conn.send("1")
conn.close()
