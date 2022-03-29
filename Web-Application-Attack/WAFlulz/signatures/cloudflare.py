#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	retval3 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"__cfduid", req.headers['set-cookie'])
	if 'server' in req.headers:
		retval2 = re.search(r"cloudflare-nginx", req.headers['server'])
	if req.text:
		retval3 = re.search(r"__cfduid|cloudflare-nginx", req.text)
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2, retval3]):
		product = "Cloudflare"
	if product is not None:
		return product

