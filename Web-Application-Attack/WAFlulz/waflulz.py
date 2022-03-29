#!/usr/bin/env python

#waflulz modules
from signatures import *
from plugins import *
import proxrand
#python 2.7 modules
import argparse
import logging
import urllib2
import httplib
import re
import os 
#3rd party modules
import requests
import tldextract

__version__ = 0.1
colorgrn = "\033[1;36m{0}\033[00m"

try:
      f = open("banner.txt", 'r')
      print f.read(),
      f.close()
except IOError:
      print "Banner Art does not exist."
print '##################################################################'
print ('####################### waflulz.py v' + str(__version__) +' ##########################')
print '###################### WAF detection tool ########################'
print '########## Written by Tony Turner | GuidePoint Security ##########'
print '##################################################################'
#define argparse options
parser = argparse.ArgumentParser(usage='%(prog)s -u [url] -n [normal] -ms [modsecurity] -a [aggressive] -r [recon]', description='waflulz accepts host input and will attempt to fingerprint any WAF in use')
parser.add_argument('-u','--url', help='python waflulz.py -u http://example.com', required=True)
parser.add_argument('-r','--recon', help='This is recon mode, where no traffic is sent to target', action='store_true')
parser.add_argument('-n','--normal', help='This is the normal mode, where no malicious requests are sent to server', action='store_true')
parser.add_argument('-ms','--modsecurity', help='This is the ModSecurity detection mode, where semi-malicious requests are sent to server', action='store_true')
parser.add_argument('-a','--aggressive', help='This is the aggressive mode, where malicious requests are sent to server to invoke WAF response', action='store_true')
parser.add_argument('-ua','--useragent', help='Define useragent string. Default is Firefox. Specify one of the following values: firefox, chrome, ie6, ie10, safari, android, bing (for bingbot), google (for googlebot)', default='firefox')
#parser.add_argument('-c','--cookie', help='Set-cookie for authenticated fingerprinting')
parser.add_argument('-p','--proxy', help='Specify to use a proxy. The proxy selected is a proxy at random from httpproxies.txt and httpsproxies.txt which is randomized for the initial request', action='store_true')
#parser.add_argument('-s','--spider', help='Extract links and follow them, spidering the site. By default only spiders base URL')
parser.add_argument ('-v','--verbose', help='INFO level verbosity. Also displays headers and requests', action='store_true')
parser.add_argument ('-vv','--verbose2', help='WARN level verbosity. Also displays headers and requests', action='store_true')
parser.add_argument ('-vvv','--verbose3', help='DEBUG level verbosity. Also displays headers and requests', action='store_true')

args = parser.parse_args()

if args.url.startswith('http' or 'https'):
	url = args.url
else:
	print 'ERROR: The URL must start with http or https'
	exit()
print ('The URL being tested is ' + colorgrn.format(str(url)))
#extract base url string, will convert string like google.com to googlecom
#domain = str(str(url.split("//")[1:]))[1:-1]
#burl = domain.replace("'","")
ext = tldextract.extract(url)
domain = '.'.join(ext[1:])
#Set unique user Agent
if args.useragent == ('google'):
	headers = {'User-Agent': 'Googlebot/2.1 (+http://www.google.com/bot.html)'}
elif args.useragent == ('bing'):
	headers = {'User-Agent': 'Mozilla/5.0 (compatible; bingbot/2.0 +http://www.bing.com/bingbot.htm)'}
elif args.useragent == ('ie6'):
	headers = {'User-Agent': 'Mozilla/5.0 (Windows; U; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)'}
elif args.useragent == ('ie10'):
	headers = {'User-Agent': 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)'}
elif args.useragent == ('chrome'):
	headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36'}
elif args.useragent == ('safari'):
	headers = {'User-Agent': 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25'} 
elif args.useragent == ('firefox'):
	headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/25.0'}
elif args.useragent == ('android'):
	headers = {'User-Agent': 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30'}

print 'The User-Agent is currently set to ' + str(headers)
'''
Logic for Recon Fingerprint
'''
def requestsRecon():
	if (args.proxy):
		r = requests.get('https://tools.digitalpoint.com/cookie-search?domain=' + domain, proxies=proxylist, headers=headers)
		print 'USING PROXY MODE'
	else:
		r = requests.get('https://tools.digitalpoint.com/cookie-search?domain=' + domain, headers=headers)
		print colorgrn.format('Performing recon on ' + domain + ' at https://tools.digitalpoint.com/cookie-search?domain=' + domain)
		return r
'''
Logic for Normal Fingerprint
'''
def requestsNormal():
	if (args.proxy):
		r = requests.get(url, proxies=proxylist, headers=headers)
		print 'USING PROXY MODE'
	else:
		r = requests.get(url, headers=headers)
	print '------------------------------------------------------------------'
	print ('The response code from ' + str(url) + ' is ' + str(r.status_code))
	print ('The set-cookie response from ' + str(url) + ' is: ')
	print 'Normal Mode does not detect the following WAFs without additional confirmation: ModSecurity'
	try:
		print r.headers['set-cookie']
	except:
		print ('There was no cookie set')
	try:
		print ('The server response from ' + str(url) + ' is ' + r.headers['server'])
	except:
		print ('The server header does not exist')
		print '------------------------------------------------------------------'
	return r



'''
Logic for Aggressive Fingerprint
'''
def requestsAggressive():
	try:
		f = open(os.path.join(os.getcwd() , "payloads.txt"), 'r')
		for line in f.readlines()[1:]:
			urlM = url + '?' + line
			if (args.proxy):
				ra = requests.get(urlM, proxies=proxylist, headers=headers)
				print 'USING PROXY MODE'
			else:
				ra = requests.get(urlM, headers=headers)
				print '------------------------------------------------------------------'
				print ('Currently testing path ' + colorgrn.format(urlM))
				print ('The response code from ' + str(urlM) + ' is ' + str(ra.status_code))
				if ra.status_code is not 200:
					print ('The response text is ' + ra.text)
				print ('The set-cookie response is: ')
				try:
					print ra.headers['set-cookie']
				except:
					print ('There was no cookie set')
				try:
					print ('The server response is ' + ra.headers['server'])
				except:
					print ('The server header does not exist')
					print '------------------------------------------------------------------'
			return ra
			f.close()
	except IOError:
		print "Aggressive mode failed, re-run in Normal mode"


'''
Logic for ModSecurity Fingerprint

'''

def requestsMS():
	try:
		f = open(os.path.join(os.getcwd() , "payloads.txt"), 'rMS')
		for line in f.readlines()[1:]:
			#below line specifically checks for modsecurity
			urlMS = url + '/?id=http?'
			if (args.proxy):
				rMS = requests.get(urlMS, proxies=proxylist, headers=headers)
				print 'USING PROXY MODE'
			else:
				rMS = requests.get(urlMS, headers=headers)
				print '------------------------------------------------------------------'
				print ('Currently testing path ' + colorgrn.format(urlMS))
				print ('The response code from ' + str(urlMS) + ' is ' + str(rMS.status_code))
				if rMS.status_code is not 200:
					print ('The response text is ' + rMS.text)
				print ('The set-cookie response is: ')
				try:
					print rMS.headers['set-cookie']
				except:
					print ('There was no cookie set')
				try:
					print ('The server response is ' + rMS.headers['server'])
				except:
					print ('The server header does not exist')
					print '------------------------------------------------------------------'
			return rMS
			f.close()
	except IOError:
		print "ModSec mode failed, re-run in Normal mode"

if (args.verbose):
	logging.basicConfig(level=logging.INFO)
	httplib.HTTPConnection.debuglevel = 1
elif (args.verbose2):
	logging.basicConfig(level=logging.WARN)
	httplib.HTTPConnection.debuglevel = 1
elif (args.verbose3):
	logging.basicConfig(level=logging.DEBUG)
	httplib.HTTPConnection.debuglevel = 1

if (args.proxy):
	proxylist = proxrand.proxRand()

if (args.recon):
	recon = requestsRecon()
	safe.safePlugins(recon)
elif (args.normal):
	r = requestsNormal()
	safe.safePlugins(r)
	partial.partialPlugins(r)
	untested.untestedPlugins(r)
elif (args.modsecurity):	
	rMS = requestsMS()
	safe.safePlugins(rMS)
	partial.partialPlugins(rMS)
	untested.untestedPlugins(rMS)
elif (args.aggressive):
	ra = requestsAggressive()
	safe.safePlugins(ra)
	partial.partialPlugins(ra)
	untested.untestedPlugins(ra)
	unsafe.unsafePlugins(ra)
	print ('Aggressive mode is now enabled. This will make a lot of noise!!')
else:
	print ('You must select an operating mode with "python waflulz.py -u http://example.com -n" for normal mode or "-a" for aggresive mode')
	exit()

	
