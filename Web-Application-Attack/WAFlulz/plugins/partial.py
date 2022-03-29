#!/usr/bin/env python
from signatures import *
import requests

colorred = "\033[01;31m{0}\033[00m"
'''
PLUGINS WORKING PARTIALLY
-------------------------
'''
def partialPlugins(req_p):
#ISA server - set-cookie match performed. Returned true on TMG reverse proxy not functioning as WAF. malicious checks not done yet
	prodName = isaserver.fingerprint(req_p)
	if prodName is not None:
		print colorred.format('The WAF detected was ' + str(prodName))