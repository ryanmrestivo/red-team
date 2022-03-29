NetBrute:

NetBrute scans a range of IP addresses for shared resources that have been shared via Microsoft File and Printer Sharing. In addition, any SMB compatible shared resources will show (i.e. Samba Servers on a Unix/Linux machine). It is to be used by system administrators or home users to see what types of resources are shared and to warn the computer users if any unsecured resources are displayed.

Ideally, only folders and printers should be shared if it is intended for the whole world to access them. If the folders and printers are not intended for the whole world, then passwords should be applied to the resources.

NetBrute will find all resources, whether they have passwords or not. However if you attempt to access a resource that is password protected, you will be prompted to enter a password. Any password that is not easily guessed is usually sufficient for protection of shared resources, however to prevent dictionary attacks, it should not be any word contained in the dictionary, any proper name, or completely numeric. A future version of NetBrute may allow a dictionary attack on password protected resources to verify that a good password scheme is implemented.

Note: You can download a brute force NetBIOS password tester here. The functionality featured in this test program will be integrated into a future version of NetBrute. There is no support for this test application, so please do not re-distribute.

To connect to the resources displayed by NetBrute:

Note: You can browse the shared resource by right-clicking on the IP or resource and choosing "Explore" from the pop-up menu. If the folder is password protected, you will be prompted to enter a password.

Choosing "Explore" from the NetBrute pop-up menu when right-clicking on a resource in the results pane, opens an actual copy of the default file browser (Windows Explorer) to allow you to have more than one folder open at a time and to provide the full features that Windows Explorer provides.

You can map to the shared resources by right-clicking on the IP address, choosing "Explore" and then right-clicking on the listed resources and choosing "Map Network Drive...".

You can also use the "File Open" dialogue by double-clicking on the IP or resources.

Warning: Running a program from a shared folder runs it on your computer.

Finally, you can copy the name to the clipboard by using "Copy" or "Copy UNC Path".

There are tools for users to see who is connected to their shared resources. Windows 9x users can run NetWatcher, and Windows NT users can use the Server utility in the Control Panel, to see who is connected to them and which resources are being used. Windows XP and 2000 users have yet another tool. The information that is displayed to them is your computer name and your user name as well as the files which you are connected to.

NetBrute shows your user name and computer name as they appear to users that you've connected to.

Note: To scan Class B networks, turn off "Class C" in the main options menu.

To get your local IP address, or to retrieve the IP address for a computer/host name, use the "Get IP" button. Use the "Copy Up" arrow button to copy the IP address into the IP range dialogue. Right-click on the "Copy Up" button to copy the IP up, using the complete Class C range (or Class B if you have Class C turned off).

To connect to printers, right-click on the printer icon and choose "Connect". A browser window will open up, listing the printer. Right-click on the printer and choose "Install..."

To increase speed, the scanner works by first scanning for listening TCP connections on NetBIOS port 139. If it finds port 139 listening from the target IP, then it attempts to get a list of shared resources and display them in the tree view.

NetBrute shows hidden resources using the, so-called obsolete, Microsoft NetShareEnum API call. This feature allows you to see hidden resources, special resources like the hidden "PRINTER$" resource, system drives, and the IPC resource. If this new feature doesn't yield satisfactory results, revert to the previous method by unchecking NetShareEnum in the Options menu.

To view all IP addresses (and their NetBIOS names) that have File and Print Sharing enabled, even if they don't have any resources shared, fill in the "Show IPCs" checkbox. Every NetBIOS enabled Windows machine should have this special hidden resource.

To view the comments for shared resources that are listed, look at the Report View.

Minimum Requirements for using NetBrute:

To use NetBrute to view or connect to shared Microsoft Resources, you must:

    Have Client for Microsoft Networks installed.
    Have File and Printer Sharing enabled.
    Have TCP/IP installed and bound to both Client for Microsoft Networks and File and Printer Sharing.
    Have Winsock v2.0 or above (Windows 95 users may have to upgrade here).



PortScan:

PortScan scans for listening TCP ports. TCP Servers of various types, such as an FTP Server, Mail Server, Telnet server, and a Web Server, generally allow users to connect to them by listening for connections on certain ports. When a client computer attempts to connect to the listening port, then the server accepts a connection and the service is ran.

Sometimes system administrators need to determine what types of services are running on computers under their care. Quite often, scanning for default ports for different types of services is the easiest way to determine that. For instance, a system administrator can quickly find all of their users who are running web servers by scanning for listening connections on port 80. Though, it is possible to setup a web server to listen on a port other than 80, it is uncommon.

Ideally, all services that can be detected in this manner, unless specifically ran for the public to access, should be password protected (with other than default passwords). Quite often a user will install a web server or a personal web server on their computer, and they use the default administration password. If an outside user detected the web server using a port scanner, they would be able to connect to the web server. They might try the default password and gain access to your user's webserver. It is always a good idea for a system administrator to find running servers and verify the security on them before users from the outside can exploit them.

Why might I use PortScan instead of my favorite Port Scanner?

PortScan creates a simple list of IP's which you can easily copy and paste into a file for processing by other means.

You can even load in your own port list to choose from. For the file format, refer to this list of common Trojan Horse TCP ports located here. You can download and modify a copy of the original port list here.

Note: To manually enter a port number, simply type it into the port selection combo box.

New! To scan all ports (1 through 65,535) simply uncheck the "Use List" checkbox.

New! To customize your default port selection list, simply download the defports.txt file, modify it, and put it in the same directory as NetBrute.exe.

To scan Class B networks, turn off Class C in the main options menu.

Clear the "Use List" check box to scan all ports 1 through 65,535.

Minimum Requirements for using Portscan:

To use PortScan to scan for open Internet service ports, you must:

    Have TCP/IP installed.
    Have Winsock v2.0 or above (Windows 95 users may have to upgrade here).



WebBrute:

WebBrute attempts a brute force userid and password attack on an HTTP Authenticated web site that is using "Basic Authentication". It is to be used by webmasters or system administrators to test the strength of their userid and password scheme on Basic Authenticated web sites.

Ideally, all passwords will be at least eight characters long and won't be: proper names, any word found in the dictionary, or completely numeric.

WebBrute allows the user to provide a text file list of users as well as a password list ("dictionary" file). All passwords from the dictionary file will be used for each username in an attempt to gain access to a specified Web URL.

If your password scheme follows the rules stated above, then your website is not likely to be broken into using this method.

If an access attempt is successful using this brute force "dictionary attack", then successful usernames/passwords pairs will be displayed. The latest successfull HTTP Reply will also be displayed in the Reply field.

What is HTTP Authentication?

Many Web Servers apply the technique differently. However, the general idea follows:

A list of usernames and passwords is generally stored on the webserver.

A directory on the webserver is configured to use the userid and password file to limit access to its contents.

See RFC 2617.

What is Basic Authentication?

There are two types of HTTP Authentication outlined in RFC 2617: Basic and Digest. Basic Authentication is unencrypted and is more easily susceptible to brute force attacks, whereas Digest Authentication is encrypted. WebBrute cannot access Digest Authenticated web sites.

Format of User and Password File:

The files should be text files with one entry per line (each entry separated by a Carriage Return and Line Feed).

HTTP Request Field:

You can use this field to add/modify the HTTP headers that will be sent with the Authentication Header for an authentication attempt. For instance, you could add a "Cookie:" header field, if necessary. Most users won't be modifying the headers and only users with knowledge of the HTTP protocol should try.

Where can you get a good password "dictionary" file?

There are some sample password "dictionary" wordlists that you can download for use with WebBrute; however, you will need to convert the Line Feeds to Carriage Return/Line Feeds. You can let your web browser do the conversion for you by simply clicking on the link to view the wordlist in the browser, then saving it as a text file. The wordlists are located at the bottom of the DES ANALYSIS page here.

New! There are two ways to run WebBrute now. If the "401 Authorization Required" replies are long, you might get better performance if you don't get the full reply (uncheck "Full Reply"), even though you have to break your connection and re-connect each time. However, if the replies are short and the server allows multiple tries on the same connection (most configurations allow three), it's probably quicker just to get the full reply because re-connecting can take awhile.

Warning: It is a bad idea to lower the WebBrute timeout. If you lower the timout so that your connections timeout, then you will be failing to properly validate the passwords. The timout has only been added to prevent it from locking up. This should be kept high. If you have problems with the connections timing out at 15 seconds, which is the default, you may wish to increase it.

Minimum Requirements for using WebBrute:

To use WebBrute to attempt a brute force attack on HTTP Basic Authentication, you must:

    Have TCP/IP installed.
    Have Winsock v2.0 or above (Windows 95 users may have to upgrade here).
