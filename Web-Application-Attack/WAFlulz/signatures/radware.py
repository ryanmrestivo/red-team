#!/usr/bin/env python
#Currently not functional
import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if req.text:
		retval = re.search(r"Unauthorized Activity Has Been Detected.+Case Number:", req.text)
    #If value was returned, identify WAF
	if retval:
		product = "AppWall (Radware)"
	if product is not None:
		return product

