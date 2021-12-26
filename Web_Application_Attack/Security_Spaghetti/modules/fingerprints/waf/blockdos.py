#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class Blockdos:
	@staticmethod
	def run(headers):
		_ = False
		for item in headers.items():
			_  = re.search(r'BlockDos[\.net]*',item[1],re.I) is not None
			if _:
				return "BlockDoS"
				break