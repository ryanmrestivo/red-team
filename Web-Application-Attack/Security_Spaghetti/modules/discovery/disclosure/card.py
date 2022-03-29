#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

from utils import parser
from utils import output

def Card(content):
	cc = parser.Parser(content).getcc()
	if len(cc) > 1:
		output.Output().plus('Found Credit Cards: %s'%str(cc).split('[')[1].split(']')[0])
	elif len(cc) == 1:
		output.Output().plus('Found Credit Card: %s'%cc[0])