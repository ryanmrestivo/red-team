#!/usr/bin/python 
# -*- coding: utf-8 -*-

import argparse
import os
from colorama import Fore,Back,Style
from ansi.colour import fg,bg 
from src.fuzzer import *
from src.ui import *

def terms():
	banner()
	print("""
WARNING: Do not use this tool for illegal activities, I am not hold responsible for any damage or halm that is done.
Using this tool to hack other peoples website can lead to some serious trouble
	""")
	agree = raw_input("Do you agree to the terms and conditions: [Y/n]: ")
	while agree == "":	
	      agree = raw_input("Do you agree to the terms and conditions: [Y/n]: ") 
		
	if (agree == "n" or agree == "N" or agree == "No" or agree == "no" or agree == "NO" or agree == "nO"):
		print("\nYou have chosen to use this tool for illegal purposes, you must agree to the terms and conditions.")		
		sys.exit(1)
	else:
		os.system('clear')
		banner()

def banner ():
	os.system('clear')
	msg = """


▀████    ▐████▀    ▄████████    ▄████████    ▄███████▄  ▄█     █▄  ███▄▄▄▄   
  ███▌   ████▀    ███    ███   ███    ███   ███    ███ ███     ███ ███▀▀▀██▄ 
   ███  ▐███      ███    █▀    ███    █▀    ███    ███ ███     ███ ███   ███ 
   ▀███▄███▀      ███          ███          ███    ███ ███     ███ ███   ███ 
   ████▀██▄     ▀███████████ ▀███████████ ▀█████████▀  ███     ███ ███   ███ 
  ▐███  ▀███             ███          ███   ███        ███     ███ ███   ███ 
 ▄███     ███▄     ▄█    ███    ▄█    ███   ███        ███ ▄█▄ ███ ███   ███ 
████       ███▄  ▄████████▀   ▄████████▀   ▄████▀       ▀███▀███▀   ▀█   █▀  
                                                                             
		     XSS EXPLOIT SCANNER
			CODEBY:Krypt0Mux                                                      
"""
	print (fg.red(msg))

terms()
parser = argparse.ArgumentParser(description='XSSPwn XSS Exploiter')
requiredNamed = parser.add_argument_group('required named arguments')
requiredNamed.add_argument('-u','--url',     help='the target url', required=True)
requiredNamed.add_argument('-l','--payloads', help='the list of payloads', required=True)
optionalNamed = parser.add_argument_group('optional named arguments')
optionalNamed.add_argument('-p', '--post', help='the post request')
args = parser.parse_args()

fuzzer = Fuzz()
fuzzer.set_url(args.url)
fuzzer.set_formdata(args.post)
fuzzer.set_payloads(args.payloads)
fuzzer.fuzz()
