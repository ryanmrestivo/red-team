#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt

from request import request
import re

class Server:
	def __init__(self,url,agent="Mozilla5/0",proxy=None,redirect=False,timeout=None,cookie=None):
		self.url = url
		self.cookie = cookie
		self.request = request.Request(
			agent=agent,
			proxy=proxy,
			redirect=redirect,
			timeout = timeout
			)

	def run(self,headers):
		server = None
		try:
			for item in headers.items():
				if re.search(r'server',item[0],re.I): server = item[1]
			if server is None:
				resp = self.request.send(self.url,headers={'Expect':'Spaghetti'},cookies=self.cookie)
				for item in resp.headers.items():
					if re.search(r'server',item[0],re.I): server = item[1]
			return server
		except Exception:
			pass