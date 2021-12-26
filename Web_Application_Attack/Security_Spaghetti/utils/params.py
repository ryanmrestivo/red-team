#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

class Params:
	def __init__(self,url,payload):
		self.url = url
		self.payload = payload

	def get(self):
		try:
			if '?' not in self.url: pass
			else:
				params = self.url.split('?')[1]
				multi_params = params.split('&')
				return multi_params
		except Exception:
			pass
	
	def post(self):
		try:
			if '?' not in self.url:
				return self.url.split('&')
		except Exception:
			pass

	def process(self):
		test_url = []
		links = []
		get = self.get()
		if get != None:
			for x in get:
				if x not in links:
					links.append(x)
		post = self.post()
		if post != None:
			for y in post:
				if y not in links:
					links.append(y)
		for param in links:
			p = param.replace(param.split('=')[1],self.payload)
			sp = param.replace(p.split('=')[1],param.split('=')[1])
			test_url.append(self.url.replace(sp,p))
		return test_url