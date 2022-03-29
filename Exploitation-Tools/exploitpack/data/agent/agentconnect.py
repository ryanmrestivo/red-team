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
import telnetlib

Host = sys.argv[1]
ShellCodePort = sys.argv[2]

print "Exploit Pack - Remote Shellcode Console\r\n"
print "Connecting to " + Host
print "Please wait...\r\n"
print "CTRL+C to exit\r\n"

try:
    TelnetConnection = telnetlib.Telnet(Host, ShellCodePort)
    print "Connected.."
    print "exploitpack>"
    TelnetConnection.interact()
except:
    print "Sorry, connection error"
