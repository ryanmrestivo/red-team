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

class AllowMethod:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url
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
		'name'        : 'AllowMethod',
		'fullname'    : 'Allow Method',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'HTTP Allow Method'
		}
		self.output.test('Checking http allow methods..')
		db = open('data/allowmethod.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		try:
			for method in dbfiles:
				resp = self.request.send(url = self.url,method = method[0],payload = None,headers = None,cookies = self.cookie)
				if re.search(r'allow|public',str(resp.headers.keys()),re.I):
					allow = resp.headers['allow']
					if allow==None:allow=resp.headers['public']
					if allow!=None and allow!='':
						self.output.plus('HTTP Allow Method: %s'%allow)
						break
		except Exception,e:
			pass