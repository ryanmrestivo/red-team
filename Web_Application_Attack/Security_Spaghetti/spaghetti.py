#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import sys
import time
import getopt
from utils import manager
from utils import banner
from utils import output
from request import urlparser
from request import ragent

class Spaghetti(object):
	bn = banner.Banner()
	pr = output.Output()
	pa = urlparser
	ma = manager
	nw = ("")
	def main(self,argv):
		agent = ragent.RAgent()
		redir = True
		time  = None
		proxy = None
		cookie = None 
		if len(sys.argv) < 2:
			self.bn.usage(True)
		try:
			opts,arg = getopt.getopt(
				argv,'u:s:',['url=','scan=','crawler','agent=','random-agent','redirect=',
				'timeout=','cookie=','proxy=','verbose','version','help']
				)
		except getopt.error,e:
			self.bn.usage(True)
		for o,a in opts:
			if o in ('-u','--url'):
				  self.url = self.target(a)
			if o in ('-s','--scan'):
				self.scan = a
			if o in ('--crawler'):pass
			if o in ('--agent'):
				agent = str(a)
			if o in ('--random-agent'):pass
			if o in ('--redirect'):
				redir = a
			if o in ('--timeout'):
				time = a
			if o in ('--cookie'):
				cookie = a 
			if o in ('--proxy'):
				proxy = a
			if o in ('--verbose'):pass
			if o in ('--version'):
				self.bn.version(True)
			if o in ('--help'):
				self.bn.usage(True)
		self.bn.banner()
		self.strftime()
		if not hasattr(self,'scan'):
			self.scan = str(0)
			self.pr.info('Scan argument is not defined, setting to default value %s'%(self.scan))
		self.ma.fingerprints(
			agent,proxy,redir,time,self.url,cookie)
		if self.scan == '0' or self.scan == '3':
			print self.nw
			urls = self.ma.crawling(
				agent,proxy,redir,time,self.url,cookie)
			if urls==[]:urls.append(self.url)
		if self.scan == '0':
			self.ma.bruteforce(
				agent,proxy,redir,time,self.url,cookie)
			self.ma.disc(
				agent,proxy,redir,time,self.url,cookie)
			self.ma.attacks(
				agent,proxy,redir,time,urls,cookie)
			self.ma.others(
				agent,proxy,redir,time,self.url,cookie)
			self.ma.vuln(
				agent,proxy,redir,time,self.url,cookie)
		if self.scan == '1':
			self.ma.bruteforce(
				agent,proxy,redir,time,self.url,cookie)
		if self.scan == '2':
			self.ma.disc(
				agent,proxy,redir,time,self.url,cookie)
		if self.scan == '3':
			self.ma.attacks(
				agent,proxy,redir,time,urls,cookie)
		if self.scan == '4':
			self.ma.others(
				agent,proxy,redir,time,self.url,cookie)
		if self.scan == '5':
			self.ma.vuln(
				agent,proxy,redir,time,self.url,cookie)

	def strftime(self):
		self.pr.plus('URL: %s'%self.url)
		self.pr.plus('Started: %s'%(str(time.strftime('%d/%m/%Y %H:%M:%S'))))
		print self.nw

	def target(self,url):
		u = self.pa.UrlParser(url).host_path()
		if u == None:
			sys.exit(self.pr.less('Url not found, please try with target url!'))
		return str(u)

if __name__ == "__main__":
	try:
		main = Spaghetti().main(sys.argv[1:])
	except KeyboardInterrupt:
		sys.exit(output.Output().less('Keyboard Interrupt by User!!'))