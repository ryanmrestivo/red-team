#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import re

class Sonicwall:
    @staticmethod
    def run(content):
        _ = False
        _  = re.search(r'This request is blocked by the SonicWALL',content,re.I) is not None
        _ |= re.search(r'Web Site Blocked.+\bnsa_banner',content,re.I) is not None
        if _:
        	return "SonicWALL (Dell)"