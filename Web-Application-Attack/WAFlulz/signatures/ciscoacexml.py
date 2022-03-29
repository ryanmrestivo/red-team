#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'server' in req.headers:
		retval = re.search(r"ACE XML Gateway", req.headers['server'])
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "Cisco ACE XML Gateway (Cisco Systems)"
	if product is not None:
		return product