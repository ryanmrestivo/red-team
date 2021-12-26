import sys
import subprocess
import os

port = sys.argv[1]
platform = sys.platform

if platform.startswith('win'):
	print "Running on Windowss"
        print "Starting Exploit Pack - Server.."
        print "Listening on port:",port
        subprocess.call("cmd.exe /K nc.exe -l %s"%port,shell=True)
elif platform.startswith('linux'):
	os.chdir("/tmp")
        file = open(port, "w")
        file.write("clear\n")
        file.write("echo Running on Linux\n")
        file.write("echo Starting Exploit Pack - Server..\n")
        file.write("echo Listening on port: %s \n"%port)
        file.write("nc -l %s \n"%port)
        file.close()
        subprocess.call("chmod +x %s"%port,shell=True)
	subprocess.call("xterm -hold -e /tmp/%s"%port,shell=True)
elif platform.startswith('darwin'):
 	os.chdir("/tmp")
	file = open(port, "w")       
	file.write("clear\n")	
	file.write("echo Running on OSX\n")
        file.write("echo Starting Exploit Pack - Server..\n")
        file.write("echo Listening on port: %s \n"%port)
	file.write("nc -l %s \n"%port)
	file.close()
        subprocess.call("chmod +x %s"%port,shell=True)
        subprocess.call("open -a Terminal /tmp/%s"%port,shell=True)
else:
	print "Sorry I could not detect the platform"
