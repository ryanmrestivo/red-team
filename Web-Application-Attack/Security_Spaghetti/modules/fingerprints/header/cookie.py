#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt

import re
from utils import output

class Cookie:
	@staticmethod	
	def run(headers):
		if headers['set-cookie']:
			cookie = headers['set-cookie']
		else:
			cookie = None
		if cookie != None:
			if re.search(r'domain=\S*',cookie,re.I):
				output.Output().plus('Cookies are only accessible to this domain: %s'%re.findall(r'domain=(.+?)[\;]',cookie,re.I)[0])
			if not re.search('httponly',cookie,re.I):
				output.Output().plus('Cookies created without HTTPOnly Flag.')
			if not re.search('secure',cookie,re.I):
				output.Output().plus('Cookies created without Secure Flag.')