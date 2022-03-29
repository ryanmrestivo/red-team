#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\APLBSID=", req.headers['set-cookie'])
	if 'server' in req.headers:
		retval2 = re.search(r"Profense", req.headers['server'])
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Profense Web Application Firewall (Armorlogic)"
	if product is not None:
		return product