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

class Dav:
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
		'name'        : 'Dav',
		'fullname'    : 'WebDav',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'WebDAV authentication bypass vulnerability (CVE-2009-1535).'
		}
		self.output.test('Checking webdav..')
		try:
			resp = self.request.send(
				url = self.url,
				method = "PROPFIND",
				payload = None,
				headers = {
						'Host':'localhost',
						'Content-Length':'0'
						},
				cookies = self.cookie
				)
			if re.search('<a:href>http://localhost/</a:href>',resp.content,re.I):
				self.output.plus('That site is may be vulnerable to WebDAV authentication bypass vulnerability, (CVE-2009-1535).')
		except Exception,e:
			pass