#!/usr/bin/env python

def fingerprint(req):
	#instantiate product
	product = None
	#Do headers exist?
	if 'set-cookie' in req.headers:
		retval = re.search(r"__cfduid", req.headers['set-cookie'])
	else:
		retval = None
    #If value was returned, identify WAF
	if retval:
		product = "SecureIIS Web Server Security (BeyondTrust)"
	if product is not None:
		return product

    #retval = code != 404
    #page, headers, code = get_page(auxHeaders={HTTP_HEADER.TRANSFER_ENCODING: 'a' * 1025, HTTP_HEADER.ACCEPT_ENCODING: "identity"})
    #retval = retval and code == 404
    #return retval
