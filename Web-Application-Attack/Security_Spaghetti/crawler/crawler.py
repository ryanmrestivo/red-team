#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re 
import sys
import urllib

from utils import output
from extractor import urlextract
from extractor import forms
from request import request
from request import urlcheck
from request import urlparser

class Crawler:
	
	def __init__(self,agent,proxy,redirect,timeout,url,cookie):
		self.url = url 
		self.cookie = cookie
		self.forms = forms.Forms()
		self.output = output.Output()
		self.ucheck = urlcheck.UrlCheck()
		self.parser = urlparser.UrlParser(url)
		self.extract = urlextract.UrlExtract()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)
	def get(self,lista1):
		lista = []
		for i in lista1:
			if re.search('=',i,re.I):
				lista.append(i)
		return lista
	
	def run(self):
		links_list = []
		try:
			for path in ('','robots.txt','sitemap.xml','spaghetti'):
				url = self.ucheck.path(self.url,path)
				resp = self.request.send(url,cookies=self.cookie)
				links = self.extract.run(resp.content)
				if links == None: link=[]
				forms = self.forms.run(resp.content,self.url)
				if forms == None: forms=[]
				links_list += links
				links_list += forms
			return self.get(self.parse(links_list))
		except Exception,e:
			pass

	def thread_run(self):
		links = self.run()
		links_list = []
		if '--crawler' in sys.argv:
			self.output.info('Starting deep crawler for %s'%self.parser.host())
			try:
				for link in links:
					resp = self.request.send(link,cookies=self.cookie)
					links_extract = self.extract.run(resp.content)
					if links_extract == None: links_extract=[]
					forms_extract = self.forms.run(resp.content,self.url)
					if forms_extract == None: forms_extract=[]
					links_list += links_extract
					links_list += forms_extract
				links_list = self.get(self.parse(links_list))
				links_list = links_list+links
				return links_list
			except Exception,e:
				pass
		return links

	def parse(self,links):
		complete = []
		flinks = []
		deflinks = []
		tlinks = []
		slinks = []
		pblacklist = []
		dlinks = []
		for link in links:
			for i in link:
				if i == '':
					pass
				else:
					if i not in flinks:
						tlinks.append(i)
		blacklist = ['.png', '.jpg', '.jpeg', '.mp3', '.mp4', '.avi', '.gif', '.svg','.pdf','.js','.zip','.css','.doc','mailto']
		for link in tlinks:
			for bl in blacklist:
				if bl in link:
					pblacklist.append(link)
		for link in tlinks:
			for bl in pblacklist:
				if bl == link:
					index = tlinks.index(bl)
					del tlinks[index]
		for link in tlinks:
			if link.startswith('./'):
				link = link.split('.')[1]
			if link.startswith('http://')or link.startswith('https://'):
				if link not in dlinks:
					dlinks.append(link)
			elif link.startswith('www.'):
				link = 'http://'+link
				if link not in dlinks:
					dlinks.append(link)
			elif link.startswith('/'):
				link = self.ucheck.path(self.url,link)
				if link not in dlinks:
					dlinks.append(link)
			else:
				link = self.ucheck.path(self.url,link)
				if link not in dlinks:
					dlinks.append(link)
		for link in dlinks:
			if not link.startswith('http'):
				pass
			elif self.parser.host() not in link:
				pass
			elif link.startswith('http://http://') or link.startswith('https://http://'):
				link = 'http'+link.split('http')[2]
				complete.append(link)
			else:
				complete.append(link)
		for i in complete:
			i = urllib.unquote(i)
			i = i.replace('&amp;','&')
			if i not in deflinks:
				deflinks.append(i)
		return deflinks
	
	def process(self):
		self.output.info('Starting crawler for %s'%self.parser.host())
		return self.thread_run()