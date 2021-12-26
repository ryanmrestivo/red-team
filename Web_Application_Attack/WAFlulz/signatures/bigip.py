#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	#Do headers exist?
	if 'X-cnection' in req.headers:
		retval = re.search(r"close", req.headers['set-cookie'])
	else:
		retval = None
	#If value was returned, identify WAF
	if any ([retval]):
		product = "BIG-IP (F5 Networks)"
	if product is not None:
		return product
