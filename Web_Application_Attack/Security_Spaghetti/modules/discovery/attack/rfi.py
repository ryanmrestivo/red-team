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

class Rfi:
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
		'name'        : 'Rfi',
		'fullname'    : 'Remote File Inclusion',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find Remote File Inclusion (RFI) Vulnerability'
		}
		self.output.test('Checking remote file inclusion...')
		db = open('data/rfi.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		pl = r"root:/root:/bin/bash|default=multi([0])disk([0])rdisk([0])partition([1])\\WINDOWS"
		try:
			for payload in dbfiles:
				for url in self.urls:
					# replace queries with payload
					param = params.Params(url,payload[0]).process()
					if len(param) > 1:
						for para in param:
							resp = self.request.send(
								url = para,
								method = "GET",
								payload = None,
								headers = None,
								cookies = self.cookie
								)
							if re.search(pl,resp.content):
								self.output.plus('That site is may be vulnerable to Remote File Inclusion (RFI) at %s'%para)
					
					elif len(param) == 1:
						resp = self.request.send(
							url = param[0],
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						if re.search(pl,resp.content):
							self.output.plus('That site is may be vulnerable to Remote File Inclusion (RFI) at %s'%param[0])
		except Exception,e:
			pass
