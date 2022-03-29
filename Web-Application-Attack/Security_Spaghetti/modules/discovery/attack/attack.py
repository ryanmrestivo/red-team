#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import rfi
import sql
import xss
import php
import ldap
import html
import xpath

from utils import output

class Attack:
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
		self.output.info('Starting attacks module...')
		rfi.Rfi(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		sql.Sql(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		xss.Xss(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		php.Php(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		ldap.LDAP(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		html.Html(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)
		xpath.Xpath(
			agent = self.agent,
			proxy = self.proxy,
			redirect = self.redirect,
			timeout = self.timeout,
			urls = self.url,
			cookie = self.cookie
			).run(
			)