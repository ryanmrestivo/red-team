#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import urlparse

class UrlParser:
	def __init__(self,url):
		self.url = url 
		self.scheme = urlparse.urlsplit(url).scheme
		self.netloc = urlparse.urlsplit(url).netloc
		self.path = urlparse.urlsplit(url).path
		self.query = urlparse.urlsplit(url).query

	def host(self):
		if self.netloc == "":
			return self.path.split('/')[0]
		else:
			return self.netloc

	def host_path(self):
		if self.netloc == "":
			return "http://"+self.path
		else:
			return self.scheme+"://"+self.netloc+self.path

	def complete(self):
		if self.netloc == "":
			return "http://"+self.path+"?"+self.query
		else:
			return self.scheme+"://"+self.netloc+self.path+"?"+self.query