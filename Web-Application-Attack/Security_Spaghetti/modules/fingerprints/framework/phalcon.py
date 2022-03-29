#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Phalcon:
	@staticmethod	
	def run(headers):
		_ = False
		for item in headers.items():
			_  = re.search(r'phalcon-auth-*',item[1],re.I) is not None
			_ |= re.search(r'Phalcon [(https://phalconphp.com/)]*',item[1]) is not None
			if _:
				return "Phalcon (C and PHP)"
				break