#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\Ast8(id|_wat|_wlf)", req.headers['set-cookie'])
	else:
		retval = None
	#If value was returned, identify WAF
	if retval:
		product = "Teros/Citrix Application Firewall Enterprise (Teros/Citrix Systems)"
	if product is not None:
		return product