#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if req.status_code == 200:
		retval = re.search(r"\ACondition Intercepted", req.text)
	if 'set-cookie' in req.headers:
		retval2 = re.search(r"\Asessioncookie=", req.headers['set-cookie'])
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Deny All Web Application Firewall (DenyAll)"
	if product is not None:
		return product
