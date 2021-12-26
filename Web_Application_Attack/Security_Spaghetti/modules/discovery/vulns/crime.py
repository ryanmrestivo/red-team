#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import socket
import subprocess

from utils import output
from request import urlparser

class Crime:
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url
		self.cookie = cookie
		self.agent = agent
		self.proxy = proxy
		self.redirect = redirect
		self.timeout = timeout
		self.output = output.Output()
		self.parser = urlparser.UrlParser(url)

	def run(self):
		info = {
		'name'        : 'Crime',
		'fullname'    : 'Crime SPDY',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'TLS protocol 1.2 and earlier, can encrypt compressed data without properly obfuscating the length of the unencrypted data'
		}
		self.output.test('Scanning crime (SPDY) vuln...')
		ip = ''
		port = '443'
		try:
			ip += socket.gethostbyname(self.parser.host())
			socket.inet_aton(ip)
			r = subprocess.Popen(['timeout','4','openssl','s_client','-connect',ip+":"+str(port),"-nextprotoneg","NULL"], stderr=subprocess.STDOUT,
				stdout=subprocess.PIPE).communicate()[0]
			if not 'Protocols advertised by server' in r:
				self.output.plus('That site is vulnerable to CRIME (SPDY), CVE-2012-4929.')
		except Exception,e:
			pass