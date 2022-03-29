#!/usr/bin/env python
from signatures import *
import requests

colorred = "\033[01;31m{0}\033[00m"
'''
PlUGINS NOT TESTED OR UNVERIFIED
-------------------------------
'''
def untestedPlugins(req_p):
#DenyAll - matches sqlmap regex but did not have sample to test.
	prodName = denyall.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Hyperguard - tested at www.riverbed.com and detected vmvisitorstate header. unsure if site is using hyperguard. Need sample
	prodName = hyperguard.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Teros - matches sqlmap regex but did not trigger on Citrix site since they appear to be using Netscaler. Need sample to test.
	prodName = teros.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Webknight - matches sqlmap regex but did not trigger on Aqtronix site. Need sample to test.
	prodName = webknight.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Datapower IBM - matches sqlmap regex but did not have sample to test.
	prodName = datapower.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Cisco ACE XML - matches sqlmap regex but did not have sample to test.
	prodName = ciscoacexml.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Netcontinuum | Barracuda - matches sqlmap regex but did not have sample to test.
	prodName = netcontinuum.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Jiasule-WAF - matches sqlmap regex but did not trigger on jiasule site. Need sample to test.
	prodName = jiasule.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#Profense - matches sqlmap regex but did not trigger on armorlogic site. Need sample to test.
	prodName = profense.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

#TrafficShield (F5) - older WAF from 2006. not tested, need test site.
	prodName = trafficshield.fingerprint(req_p)
	if prodName is not None:
		print ('The WAF detected was ' + str(prodName))

