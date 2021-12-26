#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Sitelock:
    @staticmethod
    def run(content):
        _ = False
        _  = re.search(r'SiteLock Incident ID',content,re.I) is not None
        if _:
        	return "TrueShield Web Application Firewall (SiteLock)"