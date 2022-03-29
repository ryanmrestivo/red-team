#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class Ciscoacexml:
	@staticmethod
	def run(headers):
		_ = False
		for item in headers.items():
			_  = re.search(r'ACE XML Gateway',item[1],re.I) is not None
			if _:
				return "Cisco ACE XML Gateway (Cisco Systems)"
				break