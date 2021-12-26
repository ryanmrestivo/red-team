#!/usr/bin/env python

import re
def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'server' in req.headers:
		retval = re.search(r"Secure Entry Server", req.headers['server'])
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "USP Secure Entry Server (United Security Providers)"
	if product is not None:
		return product