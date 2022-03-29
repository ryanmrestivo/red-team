#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'x-pint' in req.headers:
		retval = re.search(r"p80", req.headers['x-pint'])
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "ServerDefender Pro (Port80 Software)"
	if product is not None:
		return product

