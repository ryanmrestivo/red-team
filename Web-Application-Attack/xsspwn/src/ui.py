#!/usr/bin/python

from colorama import Fore,Back,Style
import datetime

class UI(object):

	def print_text(self, log_type, text):
		time = str(datetime.datetime.now())
		if log_type == "DEBUG":
			print(Fore.BLUE   +  "[" + time +" DEBUG]: " +  Fore.WHITE + "%s" % (text))

		if log_type == "INFO":
			print(Style.BRIGHT + Fore.GREEN  +  "[" + time + " INFO]: " + Fore.WHITE + "%s" % (text))

		if log_type == "WARNING":
			print(Fore.YELLOW +  "[" + time  + " WARNING]: " + Fore.WHITE + "%s" % (text))

		if log_type == "ERROR":
			print(Fore.RED    +  "[" + time + " ERROR]: " + Fore.WHITE + "%s" % (text))

	def print_found(self, url):
		time = str(datetime.datetime.now())
		print( Style.BRIGHT + Fore.GREEN + "[" + time +  " FOUND]: " + Style.BRIGHT + Fore.WHITE + "Potential XSS Found: \n%s"%url)
