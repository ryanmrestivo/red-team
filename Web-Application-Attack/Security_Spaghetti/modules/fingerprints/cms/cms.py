#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt


import drupal
import joomla
import wordpress
import magento

def Cms(content):
	return (
		drupal.Drupal().run(content),
		joomla.Joomla().run(content),
		wordpress.Wordpress().run(content),
		magento.Magento().run(content)
		)	