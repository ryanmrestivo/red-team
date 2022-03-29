#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os		
import subprocess

def CreateDir(target):
	try:

		path_initial = None
		path = None

		if not os.path.exists(target):
			os.mkdir(target)

		"""if os.path.exists(target):
			path_initial = subprocess.check_output('pwd', shell=True)
			print path_initial
			path= subprocess.check_output('cd ' + str(path_initial) + '/' + str(target), shell=True)
			return path"""

	except Exception as e:
		print e