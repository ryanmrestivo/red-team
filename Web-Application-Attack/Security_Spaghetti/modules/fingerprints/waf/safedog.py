#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Safedog:
    @staticmethod
    def run(headers):
        _ = False
        for item in headers.items():
            _  = re.search(r'WAF/2\.0',item[1],re.I) is not None
            _ |= re.search(r'Safedog',item[1],re.I) is not None
            if _:
                return "Safedog Web Application Firewall (Safedog)"
                break