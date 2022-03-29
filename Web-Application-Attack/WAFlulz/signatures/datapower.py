#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'X-Backside-Transport' in req.headers:
		retval = re.search(r"\A(OK|FAIL)", req.headers['X-Backside-Transport'])
	else:
		retval = None
	#If value was returned, identify WAF
	if retval:
		product = "IBM WebSphere DataPower (IBM)"
	if product is not None:
		return product