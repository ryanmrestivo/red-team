#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	#Do headers exist?
	if 'server' in req.headers:
		retval = re.search(r"jiasule-WAF", req.headers['server'])
	if req.text:
		retval2 = re.search(r"static\.jiasule\.com/static/js/http_error\.js", req.text)
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2]):
		product = "Jiasule Web Application Firewall (Jiasule)"
	if product is not None:
		return product

       
