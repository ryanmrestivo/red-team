#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class Asp:
	@staticmethod	
	def run(content,headers):
		_ = False
		for item in headers.items():
			_ = re.search(r'ASP.NET|X-AspNet-Version|x-aspnetmvc-version',str(item),re.I) is not None
			if not _:
				_ |= re.search(r'(__VIEWSTATE\W*)',content) is not None
			if not _:
				_ |= re.search(r'\.asp$|\.aspx$',content) is not None
			if _:
				return "ASP.NET"
				break