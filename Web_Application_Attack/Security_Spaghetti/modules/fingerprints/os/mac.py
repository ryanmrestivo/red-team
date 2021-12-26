#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class Mac:
	@staticmethod	
	def run(os):
		_ = False
		for item in os.items():
			_  = re.search(r'Mac|MacOS|MacOS\S*',str(item)) is not None
			if _:
				return "MacOS"
				break