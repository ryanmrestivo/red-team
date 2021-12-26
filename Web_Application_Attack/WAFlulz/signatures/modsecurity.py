#!/usr/bin/env python

#Currently not functional

import re

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if req.status_code == 501:
		#retval = re.search(r"Reference #[0-9A-Fa-f.]+", req.text)
		retval = re.search(r"Method Not Implemented", req.text)
	elif req.headers['server']:
		retval = re.search(r"Mod_Security|NOYB", req.headers['server'])
		#Send waf_payloads.py
		#retval = re.search(r"Unauthorized Activity Has Been Detected.+Case Number:", req.headers['set-cookie'])

    #If value was returned, identify WAF
	if retval:
		product = "ModSecurity: Open Source Web Application Firewall (Trustwave)"
	if product is not None:
		return product

