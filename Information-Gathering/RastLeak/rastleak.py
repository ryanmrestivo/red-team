#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import urllib2
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
#Disable warning by SSL certificate
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
import wget
#Libraries to export results
import xlsxwriter
import json
from urlparse import urlparse
from bs4 import BeautifulSoup
import optparse
#Analyze metadata pdf
import PyPDF2
from PyPDF2 import PdfFileReader
#Analyze metadata docx
import docx
import datetime
#Parser arguments
import argparse
from argparse import RawTextHelpFormatter
# encoding=utf8
import sys
reload(sys)
import os
sys.setdefaultencoding('utf8')
from time import sleep
import re #Expression regular to parse Google with Beautifoul Soup
VERSION ="2.2"
#Import modules
from modules.deleteduplicate import *
from modules.searchgoogle import *
from modules.searchbing import *
from modules.downloadfiles import *
from modules.showresults import *
from modules.createdir import *
""" FUNCTION BANNER """
def banner ():
	print """
	         _____           _   _                _    
            |  __ \         | | | |              | |   
            | |__) |__ _ ___| |_| |     ___  __ _| | __
            |  _  // _` / __| __| |    / _ \/ _` | |/ /
            | | \ \ (_| \__ \ |_| |___|  __/ (_| |   < 
            |_|  \_\__,_|___/\__|______\___|\__,_|_|\_\ """
	print "\n"
	print """** Tool to automatic leak information using Google and Bing Hacking
	** Version 2.2
	** Author: Ignacio Brihuega Rodriguez a.k.a N4xh4ck5
	** Github: https://github.com/n4xh4ck5/
	** DISCLAMER This tool was developed for educational goals. 
	** The author is not responsible for using to others goals.
	** A high power, carries a high responsibility!"""

def help ():
	print  """ \nThis script automatics leak information using Google and Bing Hacking

			Example of usage: python rastleak.py -d apple.com -o 1 -e 2 -n 5 """

""" FUNCTION MAIN """
def main (argv):
	parser = argparse.ArgumentParser(description="This script searchs files indexed in the main searches of a domain to detect a possible leak information", formatter_class=RawTextHelpFormatter)
	parser.add_argument('-d','--domain', help="The domain which it wants to search",required=True)
	parser.add_argument('-v','--version', help="Display the version (v=yes)",required=False)
	parser.add_argument('-o','--option', help="Indicate the option of search\n\t1.Searching leak information into the target\n\t2.Searching leak information outside target",required=True)
	parser.add_argument('-n','--search', help="Indicate the number of the search which you want to do",required=True)
	parser.add_argument('-e','--ext', help="Indicate the option of display:\n\t1-Searching the domains where these files are found\n\t2-Searching ofimatic files\n\n", required=True)
	parser.add_argument('-f','--export', help="Export the results in a file (Y/N)\n Format available:\n\t1.json\n\t2.xlsx", required=False)
	args = parser.parse_args()
	#Call banner
	banner()
	#call help
	help()
	initial = True #Flag to SearchBing
	catpcha = False
	url=[]
	url_google =[]
	url_google_final = []
	url_bing = []
	N = int (args.search)
	target=args.domain
	file_ext= int(args.ext)
	output = args.export
	version = args.version
	export = None
	try:
		if version is not None or version == 'yes':
			print "\nVersion: " + str(VERSION)
			exit(0)
		#Create a folder with the name of the target
		createdir.CreateDir(target)
		if output is None:
			output = 'n'
		output = output.lower()
		if (output == 'y'):
			print "Select the output format:"
			print "\n\t(js).json"
			print "\n\t(xl).xlsx"
			export = raw_input ().lower()
			if ((export != "js") and (export != "xl")):
				print "Incorrect output format selected."
				exit(1)
		option = int (args.option)
		if (option != 1) and (option != 2):
		    print "The option is not valid. Please, select a correct option"
		    exit(1)
		if option == 1:
			print "\nSearching leak information into target..."
			#Into the target
			try:
				url_google = searchgoogle.SearchGoogle(N,target,option)
				[url_google_final.append(i) for i in url_google if not i in url_google_final] 
				#Called the function to display the results
				showresults.ShowResults(url_google_final,target,option,catpcha)
				if len (url_google) < 2:
					catpcha = True
			except Exception as e:
				catpcha = False
				print e
				pass
			if catpcha == True:
				print "Do you like to use Bing to go on the leak information into target (Y/N)"
				resp = raw_input().lower()
				if (resp =='y'):
					#Call design the dork
					try:
						url_bing = searchbing.DesignDork(N,target,file_ext,initial)
						ShowResults(url_bing,target,option,catpcha)
					except: 
						pass
				elif ((resp != 'y') and (resp != 'n')):
					print "The option is not valided. Please, try again it"
				else:
					print "Exiting"
					pass
					exit (1)
		#option ==2
		else: 
			catpcha = False
			#Outside target -- Only Google
			print "Searching leak information outside target..."
			try:
				url_google = searchgoogle.SearchGoogle(N,target,option)
				#Called the function to display the results
				showresults.ShowResults(url_google,target,option,catpcha)
				if len (url_google) < 2:
					catpcha = True
			except Exception as e:
				catpcha = False
				print e
				pass
		if catpcha == False:
			#Delete duplicate
			url = deleteduplicate.DeleteDuplicate (url_google)
		else:
			url = deleteduplicate.DeleteDuplicate (url_bing)
		#verify if the user wants to export results
		#if (output =='y'):
			#Call to function to download the files		
		downloadfiles.Downloadfiles(url,export,target)
	except Exception as e:
		print e
# CALL MAIN
if __name__ == "__main__":
   main(sys.argv[1:])