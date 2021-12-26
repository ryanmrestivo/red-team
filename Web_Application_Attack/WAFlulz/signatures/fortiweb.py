#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\AFORTIWAFSID=|Fortinet", req.headers['set-cookie'])
	else:
		retval = None
	#If value was returned, identify WAF
	if retval:
		product = "FortiWeb Web Application Firewall (Fortinet Inc.)"
	if product is not None:
		return product