#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Requestvalidationmode:
    @staticmethod
    def run(content):
        _ = False
        _  = re.search(r'ASP.NET has detected data in the request that is potentially dangerous',content,re.I) is not None
        _ |= re.search(r'Request Validation has detected a potentially dangerous client input value',content,re.I) is not None
        if _:
        	return "ASP.NET RequestValidationMode (Microsoft)"