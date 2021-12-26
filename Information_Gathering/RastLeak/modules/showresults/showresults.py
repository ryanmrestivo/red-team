#!/usr/bin/env python
# -*- coding: utf-8 -*-

from modules.deleteduplicate import *
import sys
import os
#import deleteduplicate.deleteduplicate.py
#Definition and treatment of the parameters
def ShowResults(url,target,option,captcha):
	url_google =[]
	urls_bing = []
	try:
		#Delete duplicate results
		if captcha == False:
			url_google= deleteduplicate.DeleteDuplicate(url)
		else:
			url_bing = url
		#Export the urls in txt
		with open("urls.txt", "w") as text_file:
			text_file.write(str(url))
		#mv the target folder
		os.system('mv urls.txt '+ str(target))
		#clean 'u'
		if option == 1:
			print "URLS into the target "+target+" are:\n"
			if captcha == False:
				print "URLS indexed:", len (url_google)
				for i in url_google:
					#if i not in url_google:
					print i		
			else: ##Catpcha == True, try results of Bing
				print "URLs' indexed:", len (urls_bing)
				for i in urls_bing:
					#if i not in url_google:
					print i	
		else:
			#option ==2
			print "ShowResults outside target"
			print "URLS outside target "+target+" are:\n"
			print "URLS indexed:", len (url_google)
			for i in url_google:
			#if i not in url_google:
				print i	
	except Exception as e:
		print e