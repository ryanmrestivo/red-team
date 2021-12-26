#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Rails:
	@staticmethod	
	def run(headers):
		_ = False
		for item in headers.items():
			_  = re.search(r'rails*|_rails_admin_session=*|x-rails',item[1],re.I) is not None
			_ |= re.search(r'rails*|x-rails',item[0],re.I) is not None
			if _:
				return "Rails (Ruby)"
				break