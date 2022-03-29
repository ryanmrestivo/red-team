#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#searches URL?
	if req.status_code:
		retval = re.search(r"/ks-waf-error\.png", str(req.history))
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "KS-WAF (Knownsec)"
	if product is not None:
		return product
