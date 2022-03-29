#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import ip
import card
import email

from utils import output
from request import request

class Disclosure:
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
		print ""
		self.output.info('Starting disclosures module...')
		try:
			resp = self.request.send(
				url = self.url,
				method = "GET",
				payload = None,
				headers = None,
				cookies = self.cookie
				)
			ip.IP(resp.content)
			email.Email(resp.content)
			card.Card(resp.content)
		except Exception,e:
			pass