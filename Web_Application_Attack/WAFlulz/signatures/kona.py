#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if req.status_code == 501:
		retval = re.search(r"Reference #[0-9A-Fa-f.]+", req.text)
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "KONA Security Solutions (Akamai Technologies) or ModSecurity"
	if product is not None:
		return product


