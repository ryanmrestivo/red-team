#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"barracuda|barra_counter_session=|barracuda_ci_session", req.headers['set-cookie'])
	if req.text:
		retval2 = re.search(r"barracuda", req.text)
	else:
		retval = None
		#If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Barracuda Web Application Firewall (Barracuda Networks)"
	if product is not None:
		return product
