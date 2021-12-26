#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt


import asp
import java
import php	
import python
import ruby
import perl

def Lang(content,headers):
	return (
		asp.Asp().run(content,headers),
		java.Java().run(content,headers),
		php.Php().run(content,headers),
		perl.Perl().run(content,headers),
		python.Python().run(content,headers),
		ruby.Ruby().run(content,headers)
		)