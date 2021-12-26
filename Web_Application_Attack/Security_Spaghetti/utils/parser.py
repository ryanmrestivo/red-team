#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import string
import re

class Parser:
	def __init__(self,results):
		self.results = results

	def clean(self):
		self.results = re.sub('<em>','',self.results)
		self.results = re.sub('<b>','',self.results)
		self.results = re.sub('</b>','',self.results)
		self.results = re.sub('</em>','',self.results)
		self.results = re.sub('%2f',' ',self.results)
		self.results = re.sub('%3a',' ',self.results)
		self.results = re.sub('<strong>','',self.results)
		self.results = re.sub('</strong>','',self.results)
		self.results = re.sub('<wbr>','',self.results)
		self.results = re.sub('</wbr>','',self.results)
		self.results = re.sub('<li>','',self.results)
		self.results = re.sub('</li>','',self.results)

		for x in ('>', ':', '=', '<', '/', '\\', ';', '&', '%3A', '%3D', '%3C'):
			self.results = string.replace(self.results, x, " ")

	def getmail(self):
		self.clean()
		emails = re.findall(r'[a-zA-Z0-9.\-_+#~!$&\',;=:]+@+[a-zA-Z0-9-]*\.\w*',self.results)
		return emails

	def getip(self):
		self.clean()
		ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}',self.results)
		return ip

	def getcc(self):
		self.clean()
		credit_cards = re.findall(r'\d{4}[\s\-]*\d{4}[\s\-]*\d{4}[\s\-]*\d{4}',self.results)
		return credit_cards