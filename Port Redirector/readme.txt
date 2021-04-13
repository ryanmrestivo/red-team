------------------------------------------------------------------------------
FPipe v2.1 - Port redirector.
Copyright 2000 (c) by Foundstone, Inc.
http://www.foundstone.com
------------------------------------------------------------------------------

FPipe is a source port forwarder/redirector. It can create a TCP or UDP stream
with a source port of your choice. This is useful for getting past firewalls
that allow traffic with source ports of say 23, to connect with internal
servers.

Usually a client has a random, high numbered source port, which the firewall
picks off in its filter. However, the firewall might let Telnet traffic
through. FPipe can force the stream to always use a specific source port, in
this case the Telnet source port. By doing this, the firewall 'sees' the
stream as an allowed service and let's the stream through.

FPipe basically works by indirection. Start FPipe with a listening server
port, a remote destination port (the port you are trying to reach inside
the firewall) and the (optional) local source port number you want. When
FPipe starts it will wait for a client to connect on its listening port.
When a listening connection is made a new connection to the destination
machine and port with the specified local source port will be made - creating
the needed stream. When the full connection has been established, FPipe
forwards all the data received on its inbound connection to the remote
destination port beyond the firewall.

FPipe can run on the local host of the application that you are trying to use
to get inside the firewall, or it can listen on a 3rd server somewhere else.

Say you want to telnet to an internal HTTP server that you just compromised
with MDAC. A netcat shell is waiting on that HTTP server, but you can't
telnet because the firewall blocks it off. Start FPipe with the destination
of the netcat listener, a listening port and a source port that the firewall
will let through. Telnet to FPipe and you will be forwarded to the NetCat
shell. Telnet and FPipe can exist on the same server, or on different servers.

------------------------------------------------------------------------------

*** IMPORTANT ***

Users should be aware of the fact that if they use the -s option to specify
an outbound connection source port number and the outbound connection becomes
closed, they MAY not be able to re-establish a connection to the remote
machine (FPipe will claim that the address is already in use) until the
TCP TIME_WAIT and CLOSE_WAIT periods have elapsed. This time period can range
anywhere from 30 seconds to 4 minutes or more depending on which OS and
version you are using. This timeout is a feature of the TCP protocol and is
not a limitation of FPipe itself.

The reason this occurs is because FPipe tries to establish a new connection
to the remote machine using the same local IP/port and remote IP/port
combination as in the previous session and the new connection cannot be made
until the TCP stack has decided that the previous connection has completely
finished up.

------------------------------------------------------------------------------

Connection illustration
-----------------------

The connection terminology used in the program and in the following
documentation can be shown in the form of the following diagram.


Local Machine <----------> FPipe server <---------> Remote machine
                Inbound                   Outbound
               connection                connection

------------------------------------------------------------------------------

This is the usage line as reported by typing "FPipe", "FPipe -h" or
"FPipe -?".


FPipe v2.1 - TCP/UDP port redirector.
Copyright 2000 (c) by Foundstone, Inc.
http://www.foundstone.com

FPipe [-hvu?] [-lrs <port>] [-i IP] IP

 -?/-h - shows this help text
 -c    - maximum allowed simultaneous TCP connections. Default is 32
 -i    - listening interface IP address
 -l    - listening port number
 -r    - remote port number
 -s    - outbound source port number
 -u    - UDP mode
 -v    - verbose mode


Detailed option descriptions
----------------------------

-h or -?
Shows the usage of the program as in the above text.

-c
Specifies the maximum number of simultaneous TCP connections that the program
can handle. The default number is 32. If you are planning on using FPipe
for forwarding HTTP requests it might be advisable to raise this number.

-i
Specifies the IP interface that the program will listen on. If this option is
not used FPipe will listen on whatever interface the operating system
determines is most suitable.

-l
Specifies the FPipe listening server port number. This is the port number
that listens for connections on the FPipe machine.

-r
Specifies the remote port number. This is the port number on the remote
machine that will be connected to.

-s
Specifies the outbound connection local source port number. This is the
port number that data sent from the FPipe server machine will come from
when sent to the remote machine.

-u
Sets the program to run in UDP mode. FPipe will forward all UDP data sent
to and received from either side of the FPipe server (the machine on which
FPipe is running). Since UDP is a connectionless protocol the -c option is
meaningless with this option.

-v
Verbose mode. Additional information will be shown if you set the program
to verbose mode.

IP
Specifies the remote host IP address.

------------------------------------------------------------------------------


To best illustrate the use of FPipe here is an example.


Example #1:
fpipe -l 53 -s 53 -r 80 192.168.1.101

This would set the program to listen for connections on port 53 and
when a local connection is detected a further connection will be
made to port 80 of the remote machine at 192.168.1.101 with the
source port for that outbound connection being set to 53 also.
Data sent to and from the connected machines will be passed through.


==============================================================================

FOUNDSTONE, INC.

Terms of Use

1. Acceptance of Terms

1.1.
Read these Foundstone, Inc. ("Foundstone") Terms of Use ("Terms")
carefully before you ("You") accept these Terms by: (a) selecting the
"Accept" button at the end of the Terms, or (b) downloading any of the
Foundstone tools ("Tools") located on this web site.  If You do not
agree to all of these Terms, select the "Decline" button at the end of
the Terms, or do not download any of the Tools.

1.2.
The Terms are entered into by and between Foundstone and You. 
Foundstone provides the Tools to You strictly subject to the Terms.

2. Restrictions on Use

2.1.
You may not modify, reverse engineer, make derivative works of,
distribute, transmit or sell any of the Tools without the express
written consent of Foundstone. 

2.2.
The Tools may not be used by You or any other party for any purpose
that violates any local, state, federal or foreign law.  You understand
that breaking into any network or computer system not owned by You may
be illegal.

3. No Express or Implied Warranty

3.1.
THE TOOLS ARE PROVIDED TO YOU "AS IS."  FOUNDSTONE MAKES NO
WARRANTIES OR REPRESENTATIONS, EXPRESS OR IMPLIED, ABOUT THE
EFFECTIVENESS, COMPLETENESS OR FITNESS OF THE TOOLS, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE.

4. Limitation of Liability

4.1.
YOU AGREE THAT FOUNDSTONE WILL NOT BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, CONSEQUENTIAL OR PUNITIVE DAMAGES ARISING OUT OF
YOUR USE OF, OR INABILITY TO USE, THE TOOLS, INCLUDING WITHOUT
LIMITATION ANY DAMAGE TO, OR VIRUSES OR "TROJAN HORSES" THAT MAY INFECT
OR INVADE, YOUR COMPUTER EQUIPMENT OR OTHER PROPERTY, EVEN IF FOUNDSTONE
IS EXPRESSLY ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

4.2.
YOU AGREE TO HOLD FOUNDSTONE HARMLESS FROM, AND YOU COVENANT NOT TO
SUE FOUNDSTONE FOR, ANY CLAIMS BASED OR YOUR USE OF, OR YOUR INABILITY
TO USE, THE TOOLS.

5. Indemnification

5.1.
You agree to indemnify and hold Foundstone and its subsidiaries,
affiliates, officers, agents, and employees harmless from any claim or
demand, including attorney's fees, made by any third party due to or
arising out of Your use of the Tools, breach of the Terms, or violation
of the rights of another.

6. Intellectual Property Rights

6.1.
The Tools and all names, marks, brands, logos, designs, trade dress
and other designations Foundstone uses in connection with the Tools are
proprietary to Foundstone and are protected by applicable intellectual
property laws, including, but not limited to copyrights and trademarks. 
Accordingly, You may not modify, reverse engineer, make derivative works
of, distribute, transmit or sell any of the Tools, nor may You remove or
alter any of Foundstone's trademarks from the Tools or co-brand any of
the Tools, without the express written consent of Foundstone.

7. Miscellaneous

7.1.
California law and controlling United States federal law govern any
action related to the Terms.  No choice of law rules of any jurisdiction
apply.  You and Foundstone agree to submit to the personal and exclusive
jurisdiction of the California state court located in Santa Ana,
California and the United States District Court for the Central District
of California.

7.2.
The Terms constitute the entire agreement between You and
Foundstone and govern Your use of the Tools, superseding any prior
agreements between You and Foundstone (including, but not limited to,
prior versions of the Terms).

7.3.
Foundstone controls and operates this website from various
locations in the United States of America and makes no representation
that these Tools are appropriate or available for use in other
locations.  If you use this website from locations outside the United
States of America, You are responsible for compliance with applicable
local laws, including, but not limited to, the export and import
regulations of other countries.

7.4.
These Terms and this website could include inaccuracies or
typographical errors.  Foundstone may make improvements and/or changes
to the Terms or the website at any time without notice.

7.5.
The failure of Foundstone to enforce or exercise any right or
provision of the Terms does not constitute a waiver of such right or
provision.

7.6.
In the event any provision of this Agreement is held to be
unenforceable in any respect, such unenforceability shall not affect any
other provision of this Agreement, provided that the expected economic
benefits of this Agreement are not denied to either party.
