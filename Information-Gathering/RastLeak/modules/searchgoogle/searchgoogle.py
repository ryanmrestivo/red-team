#!/usr/bin/env python
import requests
import urllib2
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
#Disable warning by SSL certificate
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
import wget
#Libraries to export results
from bs4 import BeautifulSoup
import re
from urlparse import urlparse
####### FUNCTION SEARCH IN GOOGLE #######
def SearchGoogle(num,target,option):
	leak_target=""
	start_page = 0
	nlink = ""
	url_google = []
	user_agent = {'User-agent': 'Mozilla5.0'}
	contador = 100
	i = 0
	while i < num:
		i+=1
		if option == 1:
			print "\nLooking leak information into the target",target
			SearchGoogle = "https://www.google.com/search?q=(ext:pdf OR ext:doc OR ext:docx OR ext:xls OR ext:ppt)+(site:"+target+"+OR+site:*."+target+"&filter=0&num="+str(contador)
			contador+=100

		else: #option ==2
			extension = target.split(".")[1]
			leak_target = target.replace(extension,'')
			print "\nLooking leak information outside the target",target
			SearchGoogle = "https://www.google.com/search?q=site.*es+intext:"+leak_target+"+intitle:"+leak_target+"(ext:pdf OR ext:doc OR ext:docx OR ext:xls OR ext:ppt)+-site:"+target+"+-site:*."+target+"&filter=0&num="+str(contador)
			contador+=100
		try:
			response = requests.get(SearchGoogle, headers = user_agent)
		except requests.exceptions.RequestException as e:
			print "\nError connection to server!" #+ response.url,
			pass	
		except requests.exceptions.ConnectTimeout as e:
			print "\nError Timeout",target
			pass
		#Parser HTML of BeautifulSoup
		soup = BeautifulSoup(response.text, "html.parser")
		if response.text.find("Our systems have detected unusual traffic") != -1:
				print "CAPTCHA detected - Plata or captcha !!!Maybe try form another IP..."
				url_google.append("CAPTCHA detected - Plata or captcha !!!Maybe try form another IP...")
				return url_google
		#Parser url's throught regular expression
		raw_links = soup.find_all("a",href=re.compile("(?<=/url\?q=)(htt.*://.*)"))
		#print raw_links
		for link in raw_links:
			#Cache Google
			if link["href"].find("webcache.googleusercontent.com") == -1:
				nlink = link["href"].replace("/url?q=","")
			#Parser likns
			nlink = re.sub(r'&sa=.*', "", nlink)
			nlink = urllib2.unquote(nlink).decode('utf8')
			url_google.append(nlink)
		if len(raw_links) < 2:
			#Verify if Google's Captcha has caught us!
			print "No more results..."
			url_google.append("No more results")
			#captcha = True
			return url_google
		return url_google	
########################################