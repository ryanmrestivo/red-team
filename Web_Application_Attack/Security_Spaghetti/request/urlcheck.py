#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

class UrlCheck:
	def payload(self,url,payload):
		if url.endswith('/')&payload.startswith('/'):
			return url[:-1]+"?"+payload[1:]
		elif not url.endswith('/')&(payload.startswith('/')):
			return url+"?"+payload[1:]
		elif url.endswith('/')and not(payload.startswith('/')):
			return url[:-1]+"?"+payload 
		else:
			return url+"?"+payload

	def path(self,url,path):
		if url.endswith('/')&path.startswith('/'):
			if not path.endswith('/'):
				return str(url[:-1]+path)
			else:
				return str(url+path[:-1])
		elif not url.endswith('/')and not path.startswith('/'):
			if not path.endswith('/'):
				return str(url+"/"+path)
			else:
				return str(url+"/"+path[:-1])
		else:
			if not path.endswith('/'):
				return str(url+path)
			else:
				return str(url+path[:-1])