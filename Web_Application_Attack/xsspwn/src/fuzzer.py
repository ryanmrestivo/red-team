#!/usr/bin/python

"""
Import the modules
"""
from bruteforce import *
from ui import *
from user_agent import generate_user_agent
from requests import *
import sys
import os
import time

class Fuzz ():


	"""
	Assign the list of payloads
	"""
	def set_payloads (self, payloadlist):
		self.payloadlist = payloadlist


	"""
	Assign the url
	"""
	def set_url (self, url):
		self.url = url


	"""
	Return the URL
	"""
	def get_url (self,payload):
		if "INJECT" in self.url:
			newUrl = self.url.replace('INJECT', payload)
			return newUrl

		else:
			ui = UI()
			ui.print_text("ERROR", "Make Sure to put INJECT into the parameter you want to test")
			sys.exit(1)

	def set_formdata(self, postdata):
		if postdata != None:
			self.postdata = postdata			
		else:
			self.postdata = None

		

	"""
	Return the list of payloads from a file.
	"""
	def get_payload (self):
		if (os.path.isfile(self.payloadlist)):				
			 return open(self.payloadlist, 'r')
		else:
			print None

	"""
	Save the links to a file
	"""
	def save_vuln_links(self, links):
		ui = UI()
		ui.print_text("INFO", "Saving the links to a file..")
		f = open('reports/report.txt', 'w+')
		i = 0
		while i != len(links):
			f.write(links[i].encode('utf-8') + "\n")
			i = i + 1
		f.close()
		ui.print_text("DEBUG", "Done..")



	"""
	Detects a WAF Firewall
	"""
	def detect_waf(self, response):

		ui = UI()
		if ("4" in str(response)):
			ui.print_text("WARNING", "site %s seems to be behind a WAF" % self.url) 

			if response.find('WebKnight') >= 0:
	       			ui.print_text("DEBUG", "Firewall detected: WebKnight")
				return True

			elif response.find('Mod_Security') >= 0:
		      		ui.print_text("DEBUG", "Firewall detected: Mod Security")
				return True

			elif response.find('Mod_Security') >= 0:
		      		ui.print_text("DEBUG", "Firewall detected: Mod Security")
				return True

			elif response.find('dotDefender') >= 0:
		      		ui.print_text("DEBUG", "Firewall detected: Dot Defender")
				return True

			else:
	      	      		ui.print_text("INFO", "No Firewall Present")
				return False


	"""
	Read the response
	"""
	def read_response(self, session, url):
		ui = UI()

		headers = {'User-Agent': generate_user_agent(device_type="desktop", os=('mac', 'linux'))}	
		ui.print_text('DEBUG', 'Using User-Agent %s' % headers)
		page_response = session.get(url, headers=headers)

		# Detect a Web Application Firwall.
		if (self.detect_waf(page_response)):
			option = raw_input("Do you want to continue: [Y/n]: ")
			if (option == "n" or option == "N" or option == "No" or option == "no" or option == "nO"):
				# Exit because website is behind a WAF
				sys.exit(1)
			else:
				return page_response
		else:
			return page_response
	

	"""
	Start the fuzzer
	"""
	def fuzz(self):

		ui = UI()
		ui.print_text('DEBUG', "Scanning URL for XSS: %s" % self.url)
		ui.print_text('DEBUG', "Please be patient...")

		if (self.postdata != None):
			if ("^USER^" not in self.postdata or "^PASS^" not in self.postdata):
				ui = UI()
				ui.print_text("ERROR", "Make sure to put ^USER^ and ^PASS^ into the username and password fields and")
				sys.exit(1)

		payloadf = self.get_payload()
		if (payloadf == None):
			ui.print_text("ERROR", "%s Does not exist" % self.payloadlist)
			sys.exit(1)


		vulns = []
		lines = [line.decode('utf-8').strip() for line in payloadf.readlines()]
		u = self.get_url(lines[0])
		try:
			r = requests.get(u)
		except ConnectionError as e:
			ui.print_text('ERROR', 'Connection problem %s' % e)
			sys.exit(1)
		session = requests.Session()
		global c			
		c = Crack()
		c.set_loginurl(r.url)
		c.set_postdata(self.postdata)
		c.set_session(session)
		
		# Do a simple check to see if we need to login
		if ('login' in r.url):
			redir = raw_input("Do you want to redirect to %s [Y/n]:" % r.url)
			if (redir == 'Yes' or redir == 'Y' or redir == 'yes' or redir == 'y'):
				ui.print_text("DEBUG", "Redirecting to login page %s" % r.url)						
				c.bruteforce()

		for line in lines:
			payload = line
			u = self.get_url(payload)
			response = self.read_response(c.get_session(), u)		
			ui.print_text('DEBUG', 'testing -> ' + Fore.BLUE + '%s' % u)
		
			if payload.lower() in response.text.lower():
				vulns.append(u)
			time.sleep(1)


		if (len(lines) != 0):

			print "\n"
			index = 0
			percent = str(len(vulns)) +'/'+ str(len(lines))
			if (len(vulns)) == 0:
				ui.print_text('ERROR', "No Injections Found..")
				sys.exit(1)


			ui.print_text('INFO', "Injections Found: %s" %percent)
			c = raw_input('Do you want to print vulnerable links tested: [Y/n]:')
			if c == 'Y' or c == 'Yes' or c == 'y' or c == 'yes':
				print("\n\n--------------------------RESULTS---------------------------------------------------")
				for u in vulns:
					ui.print_found(u)

				print("-----------------------------------------------------------------------------------")
		
			self.save_vuln_links(vulns)
