#!/usr/bin/env python

import re

def fingerprint(req):
	#instantiate product
	product = None
	retval = None
	retval2 = None
	retval3 = None
	retval4 = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"\A(ns_af=|citrix_ns_id|NSC_)", req.headers['set-cookie'])
	if 'nnCoection' in req.headers:
		retval2 = re.search(r"", req.headers['nnCoection'])
	if 'Cneonction' in req.headers:
		retval3 = re.search(r"\Aclose", req.headers['nnCoection'])
	if req.text:
		retval4 = re.search(r"\ANS-CACHE", req.text)
	else:
		retval = None
    #If value was returned, identify WAF
	if any ([retval, retval2, retval3, retval4]):
		product = "NetScaler (Citrix Systems)"
	if product is not None:
		return product

       
