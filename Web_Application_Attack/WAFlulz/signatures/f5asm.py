#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.match(r"TS[a-zA-Z0-9]{3,6}=", req.headers['set-cookie'])
	if 'server' in req.headers:
		retval2 = re.search(r"BigIP|BIGipServer", req.headers['server'])
	else:
		retval = None
	#If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "(ASM) Application Security Manager (F5 Networks)"
	if product is not None:
		return product
