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

class Xss:
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
		'name'        : 'Xss',
		'fullname'    : 'Cross Site Scripting',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find Cross Site Scripting (XSS) vulnerability'
		}
		db = open('data/xss.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		self.output.test('Checking cross site scripting...')
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
							if resp.status_code == 200:
								if re.search(payload[0],resp.content,re.I):
									self.output.plus('That site is may be vulnerable to Cross Site Scripting (XSS) at %s'%para)
					
					elif len(param) == 1:
						resp = self.request.send(
							url = param[0],
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						if resp.status_code == 200:
							if re.search(payload[0],resp.content,re.I):
								self.output.plus('That site is may be vulnerable to Cross Site Scripting (XSS) at %s'%param[0])
		except Exception,e:
			pass
