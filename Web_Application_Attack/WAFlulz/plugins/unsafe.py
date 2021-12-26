#!/usr/bin/env python
from signatures import *
import requests

colorred = "\033[01;31m{0}\033[00m"

'''
UNSAFE PLUGINS!!
----------------
'''
def unsafePlugins(req_p):
#Radware
	prodName = radware.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#modsecurity
	prodName = modsecurity.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#PaloAlto
	prodName = paloalto.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Knownsec
	prodName = knownsec.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#DotDefender
	prodName = dotdefender.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Kona
	prodName = kona.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))


#Proventia
'''
Unsafe plugin - Malicious Request DISABLED
'''
#prodName = proventia.fingerprint(rM)
#if prodName is not None:
#	print ('The WAF detected was ' + str(prodName))


