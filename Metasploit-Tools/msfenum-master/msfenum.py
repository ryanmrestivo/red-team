#!/usr/bin/python

import logging, time, json, argparse, fileinput, re
from os import listdir, system, path, makedirs
from sys import exit

def loadConfig(currentPath):
	"""
	Loads the configuration file(s)
	"""
	try:
		with open(currentPath + '/config') as f:
			return json.load(f)
	except Exception as e:
		log.error("\033[0;31m\033[1m[!]\033[0m Failed to load config\nException: {}\n".format(str(e)))
		exit(1)


def validateModuleConfig(modules, modulesconfig, config, currentPath):
	"""
	Validates the module config
	"""
	modulesfolder = "{}/{}".format(currentPath, config.get('modulesfolder'))
	missing = []
	for module in modules:
		modulename = module.split("/")[-1]
		if (not path.isfile(path.join(modulesfolder, modulename))):
			missing.append(modulename)
	if missing:
		log.warning("Missing the following module(s): {}".format(", ".join(missing)))


def generateRcs(targets, threads, projectName, config, currentPath, logsfolder):
	"""
	Compiles all module configurations into one RC file
	"""
	modulesfolder = "{}/{}".format(currentPath, config.get('modulesfolder'))
	postmodule = "spool off\n\n"
	premodule = "spool {}/".format(logsfolder)
	modules = config.get('modules')
	modulesconfig = [f for f in listdir(modulesfolder) if path.isfile(path.join(modulesfolder, f))]

	validateModuleConfig(modules, modulesconfig, config, currentPath)

	if threads == None:
		threads = str(config.get('defaultthreads'))

	rcfile = ""
	for target in targets:
		for module in modules:
			modulename = module.split("/")[-1]
			settings = config.get('settings')
			try:
				run = True
				customSettings = True
				for key, value in settings[module].iteritems():
					if value == "CHANGEME":
						run = False
				if run == True:
					log.info("Custom settings defined for module {}".format(module))
				else:
					log.warn("Custom settings not defined for module {}".format(module))
			except:
				run = True
				customSettings = False
			if run == True:
				if (path.isfile(path.join(modulesfolder,modulename))):
					rcfile += "setg threads {}\n".format(str(threads))
					rcfile += "{}{}/{}.log\n".format(premodule, projectName, modulename)
					rcfile += "use {}\n".format(module)
					if customSettings == True:
						for key, value in settings[module].iteritems():
							rcfile += "set {} {}\n".format(key, value)
					rcfile += open(path.join(modulesfolder,modulename),'r').read().replace("%IP%", target)
					rcfile += postmodule
	rcfile += "exit -y\n"
	rcoutput = open("{}/{}/file.rc".format(logsfolder, projectName), 'w')
	rcoutput.write(rcfile)
	rcoutput.close()

def runRcs(projectName, config, logsfolder):
	"""
	Runs metasploit commands and prints output
	"""
	log.critical('--- Starting msfconsole ---')
	system('msfconsole -r {}/{}/file.rc'.format(logsfolder, projectName))
	log.info('\n--- Msfconsole done ---\n')


def getSuccessful(projectName, config, logsfolder):
	"""
	Prints all [+] entries in the log in context. 
	"""
	log.critical('--- Summary of discovered results ---')
	for f in listdir("{}/{}".format(logsfolder, projectName)):

		if f.endswith(".log"):
			log.warning('- Module: {}'.format(f.rsplit('.', 1)[0]))
			result = system('grep [+] {}/{}/{}'.format(logsfolder, projectName, f))

			if result == 256: # No results end in a 256
				log.debug("No results")
			elif result == 0: # All results printed end in 0
				pass
			else:
				log.critical(re.sub(r"\[\+]", "\033[0;32m\033[1m[+]\033[0m",result))

	log.critical('--- Msfenum done ---')


class logFormat(logging.Formatter):
	"""
	Custom logging formatter
	"""

	crit_fmt = "%(msg)s" # no format
	err_fmt  = "\033[0;33m\033[1m[!]\033[0m %(msg)s" # bold yellow [!]
	warn_fmt = "\033[0;34m\033[1m[*]\033[0m %(msg)s" # bold blue [*]
	info_fmt = "\033[0;32m\033[1m[+]\033[0m %(msg)s" # bold green [+]
	dbg_fmt  = "\033[0;31m\033[1m[-]\033[0m %(msg)s" # bold red [-]


	def __init__(self, fmt="%(levelno)s: %(msg)s"):
		logging.Formatter.__init__(self, fmt)


	def format(self, record):

		# Save the original format configured by the user
		# when the logger formatter was instantiated
		format_orig = self._fmt

		# Replace the original format with one customized by logging level
		if record.levelno == logging.DEBUG:
			self._fmt = logFormat.dbg_fmt

		elif record.levelno == logging.INFO:
			self._fmt = logFormat.info_fmt

		elif record.levelno == logging.WARN:
			self._fmt = logFormat.warn_fmt

		elif record.levelno == logging.ERROR:
			self._fmt = logFormat.err_fmt

		elif record.levelno == logging.CRITICAL:
			self._fmt = logFormat.crit_fmt

		# Call the original formatter class to do the grunt work
		result = logging.Formatter.format(self, record)

		# Restore the original format configured by the user
		self._fmt = format_orig

		return result


def ascii():
	"""
	We need some ASCII
	"""
	print(r"""
	             . --- .
	           /        \
	          |  O  _  O |
	          |  ./   \. |
	          /  `-._.-'  \
	        .' /         \ `.
	    .-~.-~/           \~-.~-.
	.-~ ~    |             |    ~ ~-.
	`- .     |             |     . -'
	     ~ - |             | - ~
	         \             /
	       ___\           /___
	       ~;_  >- . . -<  _i~
	          `'         `'
	By: @wez3forsec, @rikvduijn, @Ag0s_
	      """)


if __name__ == '__main__':
	# Define logger settings
	currentPath = path.dirname(path.abspath(__file__))
	logfile= "{}/msfenum.log".format(currentPath)
        logging.basicConfig(filename=logfile, level=logging.DEBUG)
        log = logging.getLogger()
        handler = logging.StreamHandler()
        handler.setFormatter(logFormat())
        log.addHandler(handler)
        ascii()

	# Load config with default settings
	config = loadConfig(currentPath)

	# Define variables
	logsfolder = "{}/{}".format(currentPath, config.get('logsfolder'))
	projectName = None
	targets = []
	threads = None

	# Parse command line arguments
	parser = argparse.ArgumentParser(description="Metasploit framework auto enumeration script")
	parser.add_argument('-t', '--threads', nargs='?', help='Number of threads', type=int)
	parser.add_argument('-p', '--project', nargs='?', help='Project name', type=str)
	parser.add_argument('files', metavar='TARGET_FILE', help='File containing targets')
	args = parser.parse_args()

	# Check if target file is accessible and load it
	if not path.isfile(args.files):
		exit('\033[0;31m\033[1m[!]\033[0m Target file does not exist')
	for target in fileinput.input(files=args.files if len(args.files) > 0 else ('-', )):
		targets.append(target)

	# Check if threads are specified.
	if args.threads is not None:
		threads = args.threads

	if args.project is None:
		projectName = str(int(time.time()))
	else:
		projectName = args.project

	log.critical('--- Starting msfenum ---')

	# Create current run directory
	try:
		currentDir = "{}/{}".format(logsfolder, projectName)
		makedirs(currentDir)
		log.warn('Saving msfenum logs in: {}'.format(currentDir))
	except:
		exit('\033[0;31m\033[1m[!]\033[0m Could not create directory structure')

	# Run the script
	generateRcs(targets, threads, projectName, config, currentPath, logsfolder)
	runRcs(projectName, config, logsfolder)
	getSuccessful(projectName, config, logsfolder)
