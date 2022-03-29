#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import dir
import log
import bdir
import file
import admin
import bfile
import backdoor

from utils import output

class Brute:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.agent = agent
		self.proxy = proxy
		self.redirect = redirect
		self.timeout = timeout
		self.url = url 
		self.cookie = cookie
		self.output = output.Output()

	def run(self):
		print ""
		self.output.info('Starting bruteforce module...')
		file.File(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		admin.Admin(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		backdoor.Backdoor(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		bdir.Bdir(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		bfile.Bfile(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		dir.Dir(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)
		log.Log(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			url = self.url,
			cookie = self.cookie
			).run(
			)