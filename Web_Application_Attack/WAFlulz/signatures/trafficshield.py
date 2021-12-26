#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\AASINFO=", req.headers['set-cookie'])
	if 'server' in req.headers:
		retval2 = re.search(r"F5-TrafficShield", req.headers['server'])
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "TrafficShield (F5 Networks)"
	if product is not None:
		return product