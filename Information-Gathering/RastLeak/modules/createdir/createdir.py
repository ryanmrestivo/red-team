#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os		

def CreateDir(target):
	try:

		path_initial = None
		path = None

		if not os.path.exists(target):
			os.mkdir(target)
			temp = str(target) + '/temp'
			os.mkdir(temp)

	except Exception as e:
		print e
