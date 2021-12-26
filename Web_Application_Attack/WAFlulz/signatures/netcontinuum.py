#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\ANCI__SessionId=", req.headers['set-cookie'])
	else:
		retval = None
	#If value was returned, identify WAF
	if retval:
		product = "NetContinuum Web Application Firewall (NetContinuum/Barracuda Networks)"
	if product is not None:
		return product