#!/usr/bin/env python

#Not currently working. Replace signature below
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
		product = "webApp.secure (webScurity)"
	if product is not None:
		return product

#def detect(get_page):
#    page, headers, code = get_page()
#    if code == 403:
#        return False
#    page, headers, code = get_page(get="nx=@@")
#    return code == 403
