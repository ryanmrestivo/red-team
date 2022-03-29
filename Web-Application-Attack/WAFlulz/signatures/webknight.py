#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'server' in req.headers:
		retval = re.search(r"WebKnight", req.headers['server'])
	#if req.status_code == 501:
		#retval2 = True
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "WebKnight Application Firewall (AQTRONIX)"
	if product is not None:
		return product
