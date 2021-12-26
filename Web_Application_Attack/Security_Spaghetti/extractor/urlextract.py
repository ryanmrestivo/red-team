#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class UrlExtract:
	@staticmethod
	def run(content):
		try:
			urls = re.findall(r'href=[\'"]?([^\'" >]+)|Allow: (\/.*)|Disallow: (\/.*)|<loc>(.+?)</loc>',content)
			return urls
		except Exception,e:
			pass