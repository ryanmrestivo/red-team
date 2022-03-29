#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	retval3 = None
	#Do headers exist?
	if 'x-binarysec-via' in req.headers:
		retval = re.search(r".", req.headers['x-binarysec-via'])
	if 'x-binarysec-nocache' in req.headers:
		retval2 = re.search(r".", req.headers['x-binarysec-nocache'])
	if 'server' in req.headers:
		retval3 = re.search(r"BinarySec", req.headers['server'])
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2, retval3]):
		product = "BinarySEC Web Application Firewall (BinarySEC)"
	if product is not None:
		return product

       
