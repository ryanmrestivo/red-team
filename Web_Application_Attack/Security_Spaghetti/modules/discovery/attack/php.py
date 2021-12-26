#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

from utils import output
from utils import params
from request import request

class Php:
	def __init__(self,agent,proxy,redirect,timeout,urls,cookie):
		self.urls = urls
		self.cookie = cookie
		self.output = output.Output()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)

	def run(self):
		info = {
		'name'        : 'Php',
		'fullname'    : 'PHP Code Injection',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find PHP Code Injection Vulnerability'
		}
		self.output.test('Checking php code injection...')
		payload = "1;phpinfo()"
		try:
			for url in self.urls:
				param = params.Params(url,payload).process()
				if len(param) > 1:
					for para in param:
						resp = self.request.send(
							url = para,
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						if resp.status_code == 200:
							if re.search(r'<title>phpinfo[()]</title>|<h1 class="p">PHP Version (.*?)</h1>',resp.content):
								self.output.plus('That site is may be vulnerable to PHP Code Injection at %s'%para)
					
				elif len(param) == 1:
					resp = self.request.send(
						url = param[0],
						method = "GET",
						payload = None,
						headers = None,
						cookies = self.cookie
						)
					if resp.status_code == 200:
						if re.search(r'<title>phpinfo[()]</title>|<h1 class="p">PHP Version (.*?)</h1>',resp.content):
							self.output.plus('That site is may be vulnerable to PHP Code Injection at %s'%param[0])
		except Exception,e:
			pass
