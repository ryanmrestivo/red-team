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
from request import urlcheck

class Robots:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url
		self.cookie = cookie
		self.output = output.Output()
		self.ucheck = urlcheck.UrlCheck()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)
	
	def run(self):
		info = {
		'name'        : 'Robots',
		'fullname'    : 'Robots',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Checking Robots Paths'
		}
		self.output.test('Checking robots paths..')
		try:
			url = self.ucheck.path(self.url,'robots.txt')
			resp = self.request.send(
				url = url,
				method = "GET",
				payload = None,
				headers = None,
				cookies = self.cookie
				)
			if resp.url == url:
				paths = re.findall(r'\ (/\S*)',resp.content)
				if paths != []:
					print ""
					for path in paths:
						if path.startswith('/'): path = path[1:]
						url2 = self.ucheck.path(self.url,path)
						resp = self.request.send(
							url=url2,
							method="GET",
							payload=None,
							headers=None,
							cookies=self.cookie
							)
						print " - [%s] %s"%(resp.status_code,url2)
					print ""
		except Exception,e:
			pass