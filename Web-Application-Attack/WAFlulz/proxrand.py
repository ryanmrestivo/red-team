#!/usr/bin/env python

import random

colorgrn = "\033[1;36m{0}\033[00m"

def proxRand():
	httpprox = open('httpproxies.txt').read().splitlines()
	myHTTPProxy = random.choice(httpprox)
	httpsprox = open('httpsproxies.txt').read().splitlines()
	myHTTPSProxy = random.choice(httpsprox)
	print colorgrn.format('My HTTP proxy is ' + myHTTPProxy + ' and my HTTPS proxy is ' + myHTTPSProxy)
	proxylist = {'http': myHTTPProxy, 'https': myHTTPSProxy}
	return proxylist