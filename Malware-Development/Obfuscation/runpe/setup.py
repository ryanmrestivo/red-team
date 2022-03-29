#!/usr/bin/env python

# This script converts python file to executable

from distutils.core import setup 
import py2exe 
import sys, shutil


sys.argv.append('py2exe')
setup(
	options={
		'py2exe':{'bundle_files':1, 'compressed':True}
	},
	console=[
		{'script':"runpe_final.py"}
	],
	zipfile=None,
)

shutil.move('dist\\runpe_final.exe', '.\\runpe_final.exe')
shutil.rmtree('build')
shutil.rmtree('dist')
