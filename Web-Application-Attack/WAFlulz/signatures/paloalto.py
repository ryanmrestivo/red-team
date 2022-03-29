#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if req.status_code != 404:
		retval = re.search(r"Access[^<]+has been blocked in accordance with company policy", req.text)
	else:
		retval = None
		#If value was returned, identify WAF
	if retval:
		product = "Palo Alto Firewall (Palo Alto Networks)"
	if product is not None:
		return product
