#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

from utils import parser
from utils import output

def Email(content):
	list_email = parser.Parser(content).getmail()
	if len(list_email) > 1:
		output.Output().plus('Found Emails: %s'%str(list_email).split('[')[1].split(']')[0])
	elif len(list_email) == 1:
		output.Output().plus('Found Email: %s'%list_email[0])