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

class Xpath:
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
		'name'        : 'XPath',
		'fullname'    : 'XPath Injection',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find XPATH Injection'
		}
		db = open('data/xpath.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		self.output.test('Checking xpath injection...')
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
							if re.search(r'XPATH syntax error:|XPathException',resp.content,re.I):
								self.output.plus('That site is may be vulnerable to XPath Injection at %s'%para)
					
					elif len(param) == 1:
						resp = self.request.send(
							url = param[0],
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						if re.search(r'XPATH syntax error:|XPathException',resp.content,re.I):
							self.output.plus('That site is may be vulnerable to XPath Injection at %s'%param[0])
		except Exception,e:
			pass
