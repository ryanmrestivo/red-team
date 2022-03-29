import socket
import sys
s = socket.socket()
s.bind(("localhost",9999))
s.listen(10)

i=1

while True:
    sc, address = s.accept()
    print address
    f = open('file_'+str(i)+".pdf",'wb') #open in binary
    i=i+1
    print(i)
    l = 1
    while(l):
        l = sc.recv(1024)
        while (l):
            f.write(l)
            l = sc.recv(1024)
        f.close()
    sc.close()
s.close()
