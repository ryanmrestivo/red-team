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
from request import urlcheck

class Dir:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url
		self.cookie = cookie
		self.output = output.Output()
		self.ucheck = urlcheck.UrlCheck()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)
	
	def run(self):
		info = {
		'name'        : 'Dir',
		'fullname'    : 'Common Directory',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find Common Directory'
		}
		self.output.test('Checking common dirs..')
		db = open('data/cdir.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		try:
			for d in dbfiles:
				url = self.ucheck.path(self.url,d[0])
				resp = self.request.send(
					url = url,
					method = "GET",
					payload = None,
					headers = None,
					cookies = self.cookie
					)
				if resp.status_code == 200:
					if resp.url == url+"/".replace(' ','%20'):
						self.output.plus('Found "%s" directory at %s'%(d[0],resp.url))
						if re.search(r'Index Of|<a href="?C=N;O=D">Name</a>|<A HREF="?M=A">Last modified</A>|Parent Directory</a>|<TITLE>Folder Listing.|<<table summary="Directory Listing"',resp.content,re.I):
							self.output.plus('Indexing enabled at %s'%(resp.url))
		except Exception,e:
			print e