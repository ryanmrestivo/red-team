#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

from utils import output
from utils import params
from request import request

class LDAP:
	def __init__(self,agent,proxy,redirect,timeout,urls,cookie):
		self.urls = urls
		self.cookie = cookie
		self.output = output.Output()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)

	def errors(self,data):
		error = (
			"supplied argument is not a valid ldap",
			"javax.naming.NameNotFoundException",
			"javax.naming.directory.InvalidSearchFilterException",
			"Invalid DN syntax",
			"LDAPException|com.sun.jndi.ldap",
			"Search: Bad search filter",
			"Protocol error occurred",
			"Size limit has exceeded",
			"The alias is invalid",
			"Module Products.LDAPMultiPlugins",
			"Object does not exist",
			"The syntax is invalid",
			"A constraint violation occurred",
			"An inappropriate matching occurred",
			"Unknown error occurred",
			"The search filter is incorrect",
			"Local error occurred",
			"The search filter is invalid",
			"The search filter cannot be recognized",
			"IPWorksASP.LDAP"
			)
		for erro in error:
			if re.search(erro,data):
				return "LDAP Injection"
				break
	
	def run(self):
		info = {
		'name'        : 'LDAP',
		'fullname'    : 'LDAP Injection',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find LDAP Injection'
		}
		self.output.test('Checking ldap injection...')
		db = open('data/ldap.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		try:
			for payload in dbfiles:
				for url in self.urls:
					# replace queries with payload
					param = params.Params(url,payload[0]).process()
					if len(param) > 1:
						for para in param:
							resp = self.request.send(
								url = para,
								method = "GET",
								payload = None,
								headers = None,
								cookies = self.cookie
								)
							if self.errors(resp.content):
								self.output.plus('That site is may be vulnerable to LDAP Injection at %s'%para)
					
					elif len(param) == 1:
						resp = self.request.send(
							url = param[0],
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						if self.errors(resp.content):
							self.output.plus('That site is may be vulnerable to LDAP Injection at %s'%param[0])
		except Exception,e:
			pass
