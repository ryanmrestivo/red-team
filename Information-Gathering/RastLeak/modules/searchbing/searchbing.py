#!/usr/bin/env python
import requests
#Libraries to export results
from bs4 import BeautifulSoup
from urlparse import urlparse
import optparse

delete_bing=["microsoft","msn","bing"]
####### FUNCTION CREATE A DORK ######
#********************************************************#
#Define and design the dork
def DesignDork (num,target,file_ext,initial):
	dork=["site:","-site:","filetype:","intitle:","intext:"]
	iteration=0
	initial=1
	count_bing=9
	try:
		while (iteration < num):
			#WAITING A DORK IN BING
			iteration += 1
			if initial == True:
				initial = False
				print "\nSearching possible leak information...\n"
				#First search in Bing
				SearchBing = "https://www.bing.com/search?q="+dork[0]+target+" ("+dork[2]+"pdf+OR+"+dork[2]+"doc)&go=Buscar"
			else:
				#Bring the next Bing results - 50 in each page
				SearchBing=SearchBing + "&first="+str(count_bing)+"&FORM=PORE"
				count_bing=count_bing+50
			response=requests.get(SearchBing,allow_redirects=True,timeout=10,verify=False)
			urls_final = parser_html(response.text,file_ext)
			#return urls_final
	except Exception as e:
		#print e
		pass
	return urls_final
#********************************************************#
####### FUNCTION PARSER HTML ######
#Definition and treatment of the parameters
def parser_html(content,type):
	urls = []
	urls_clean = []
	urls_final =[]
	i = 0
	soup = BeautifulSoup(content, 'html.parser')
	try:
		for link in soup.find_all('a'):
			#try:
			if (urlparse(link.get('href'))!='' and urlparse(link.get('href'))[1].strip()!=''):	
				#if file_ext == 1: -> Display the domains where the files are found.
				if type == 1:
					urls.append(urlparse(link.get('href'))[1]) #domain
				else: # file_ext == 2 -> ofimatic files: pdf, doc,docx,xls,....
					urls.append(link.get('href'))
			#Delete duplicates
			[urls_clean.append(i) for i in urls if not i in urls_clean] 
			#Delete not domains belongs to target
			for value in urls_clean:
				if (value.find(delete_bing[0])  == -1):
					if (value.find(delete_bing[1])  == -1):
						if (value.find(delete_bing[2])  == -1):
							urls_final.append(value)
							#return urls_final
	except Exception as e:
		pass
	return urls_final