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
		retval = re.match(r"ISA", req.headers['set-cookie'])
	if req.text:
		retval2 = re.match(r"The server denied the specified Uniform Resource Locator (URL). Contact the server administrator.", req.text)
	if req.text:
		retval3 = re.match(r"The ISA Server denied the specified Uniform Resource Locator (URL)", req.text)
	else:
		retval = None
	#If value was returned, identify WAF
	if any([retval, retval2, retval3]):
		product = "ISA Server or TMG (Microsoft)"
	if product is not None:
		return product
