import sys
import subprocess
import os

host = sys.argv[1]
port = sys.argv[2]
platform = sys.platform

if platform.startswith('win'):
	print "Running on Windowss"
        print "Starting Exploit Pack - Client.."
        print "Connecting to:",host
        subprocess.call("cmd.exe /K nc.exe %s %s"%(host,port),shell=True)
elif platform.startswith('linux'):
	os.chdir("/tmp")
        file = open(port, "w")
        file.write("clear\n")
        file.write("echo Running on Linux\n")
        file.write("echo Starting Exploit Pack - Client..\n")
        file.write("echo Connecting to: %s \n"%host)
        file.write("nc %s %s\n"%(host,port))
        file.close()
        subprocess.call("chmod +x %s"%port,shell=True)
	subprocess.call("xterm -hold -e /tmp/%s"%port,shell=True)
elif platform.startswith('darwin'):
	os.chdir("/tmp")
 	file = open(port, "w")       
	file.write("clear\n")	
	file.write("echo Running on OSX\n")
        file.write("echo Starting Exploit Pack - Client..\n")
        file.write("echo Connecting to: %s \n"%host)
	file.write("nc %s %s\n"%(host,port))
	file.close()
        subprocess.call("chmod +x %s"%port,shell=True)
        subprocess.call("open -a Terminal /tmp/%s"%port,shell=True)
else:
	print "Sorry I could not detect the platform"
