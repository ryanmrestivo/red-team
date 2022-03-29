#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import sys
import ragent
import urllib3
import urlcheck
import requests

class Request:
	def __init__(self,**kwargs):
		self.agent = None if "agent" not in kwargs else kwargs["agent"]
		self.proxy = None if "proxy" not in kwargs else	kwargs["proxy"]
		self.redirect = True if "redirect" not in kwargs else kwargs["redirect"]
		self.timeout = None if "timeout" not in kwargs else kwargs["timeout"]
		self.ragent = ragent.RAgent()
		self.ucheck = urlcheck.UrlCheck()

	def send(self,url,method="GET",payload=None,headers=None,cookies=None):
		if payload is None: payload = {}
		if headers is None: headers = {}
		if cookies is not None: cookies = {cookies:''}
		if "--random-agent" in sys.argv:
			headers['User-Agent'] = self.ragent
		else:
			headers['User-Agent'] = self.agent
		# requests session
		request = requests.Session()
		req = urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
		# get method 
		if method.upper() == "GET":
			if payload: url = "%s"%Request.check.payload(url,payload)
			req = request.request(
				method = method.upper(),
				url = url,
				headers = headers,
				cookies = cookies,
				timeout = self.timeout,
				allow_redirects = self.redirect,
				proxies = {
							'http' : self.proxy,
							'https': self.proxy,
							'ftp'  : self.proxy,
							},
				verify = False
				)
		# post method
		elif method.upper() == "POST":
			req = request.request(
				method = method.upper(),
				url = url,
				data = payload,
				headers = headers,
				cookies = cookies,
				timeout = self.timeout,
				allow_redirects = self.redirect,
				proxies = {
							'http' : self.proxy,
							'https': self.proxy,
							'ftp'  : self.proxy
							},
				verify = False
				)
		# other methods
		else:
			req = request.request(
				method = method.upper(),
				url = url,
				data = payload,
				headers = headers,
				cookies = cookies,
				timeout = self.timeout,
				allow_redirects = self.redirect,
				proxies = {
							'http' : self.proxy,
							'https': self.proxy,
							'ftp'  : self.proxy
							},
				verify = False
				)
		# return all "req" attrs
		return req