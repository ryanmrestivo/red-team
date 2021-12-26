#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Fortiweb():
    @staticmethod
    def run(headers):
        _ = False
        for item in headers.items():
            _ = re.search(r'FORTIWAFSID=',item[1],re.I) is not None
            if _:
                return "FortiWeb Web Application Firewall (Fortinet)"
                break