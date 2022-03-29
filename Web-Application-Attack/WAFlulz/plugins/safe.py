#!/usr/bin/env python
from signatures import *
import requests

colorred = "\033[01;31m{0}\033[00m"
'''
SAFE PLUGINS - VERIFIED AND TESTED 131101
-----------------------------------------
'''
def safePlugins(req_p):
#Incapsula / Imperva
	prodName = incapsula.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Cloudflare	
	prodName = cloudflare.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#BigIP
	prodName = bigip.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#F5ASM
	prodName = f5asm.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Barracuda
	prodName = barracuda.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Port80
	prodName = port80.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Netscaler
	prodName = netscaler.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#Fortiweb
	prodName = fortiweb.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#BinarySec
	prodName = binarysec.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
#United Security Providers Secure Entry Server
	prodName = uspses.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))
	return req_p