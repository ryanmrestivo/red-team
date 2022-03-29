#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re
import urllib

from utils import text
from request import urlcheck
from BeautifulSoup import BeautifulSoup

class Forms:
	def run(self,content,url):
		forms = []
		try:
			soup = BeautifulSoup(content)
			for match in soup.findAll('form'):
				if match not in forms:
					forms.append(match)
			for form in forms:
				return urlcheck.UrlCheck().path(url,self.extractor(form))
		except Exception,e:
			pass

	def extractor(self,form):
		form = text.UTF8(form)
		method = []
		action = []
		names = []
		values = []
		try:
			method += re.findall(r'method=[\"](.+?)[\"]',form,re.I)
			action += re.findall(r'action=[\"](.+?)[\"]',form,re.I)
			names += re.findall(r'name=[\"](.+?)[\"]',form,re.I)
			values += re.findall(r'value=(\S*)',form,re.I)
		except Exception,e:
			pass
		params = []
		try:
			for i in range(len(names)):
				values[i] = values[i].split('"')[1]
				params.append(names[i])
				params.append(values[i])
		except:
			pass
		try:
			params = zip(*[iter(params)]*2)
			data = urllib.unquote(urllib.urlencode(params))
			if method == []:
				method = ['get']
			method = method[0]
			if method.upper() == "GET":
				return data
		except Exception,e:
			pass