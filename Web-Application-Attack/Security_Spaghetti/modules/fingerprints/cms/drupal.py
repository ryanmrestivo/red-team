#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

class Drupal:
	@staticmethod	
	def run(content):
		_ = False
		try:
			_ = re.search(r'src="\S*/misc/drupal.js*|Powered by Drupal, an open source content management system',content) is not None
			_ |= re.search(r'\S*/misc/drupal.css"|jQuery.extend\WDrupal.settings|Drupal.extend\W',content) is not None
			_ |= re.search(r'<meta name="Generator" content="Drupal',content) is not None
			if _:
				return "Drupal"
		except Exception,e:
			pass