import subprocess
 
ipaddr = raw_input("Enter the IP address of the mysql server: ")
 
while 1:
    subprocess.Popen("mysql --host=%s -u root mysql --password=blah" % (ipaddr), shell=True).wait()
