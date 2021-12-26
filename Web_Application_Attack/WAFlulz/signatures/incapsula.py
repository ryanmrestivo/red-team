#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"incap_ses|visid_incap", req.headers['set-cookie'])
	if req.text:
		retval2 = re.search(r"incap_ses|visid_incap", req.text)
	else:
		retval = None
	#If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Incapsula Web Application Firewall (Incapsula/Imperva)"
	if product is not None:
		return product
