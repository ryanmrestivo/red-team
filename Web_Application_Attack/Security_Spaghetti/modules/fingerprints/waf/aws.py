#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Aws():
	@staticmethod
	def run(headers):
		_ = False
		for item in headers.items():
			_  = re.search(r'aws*',item[1],re.I) is not None
			_ |= re.search(r'x-amz-id-[0-2]',item[0],re.I) is not None
			_ |= re.search(r'x-amz-request-id',item[0],re.I) is not None
			if _: 
				return 'Amazon Web Services Web Application Firewall (Amazon)'
				break