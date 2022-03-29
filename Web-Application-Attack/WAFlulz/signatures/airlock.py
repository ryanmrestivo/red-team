#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\AAL[_-]?(SESS|LB)=", req.headers['set-cookie'])
	if req.text:
		retval2 = re.search(r"\AAL[_-]?(SESS|LB)=", req.text)
	else:
		retval = None
	#If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Airlock (Phion/Ergon)"
	if product is not None:
		return product

      
