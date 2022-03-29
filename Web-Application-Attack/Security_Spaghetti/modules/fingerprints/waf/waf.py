#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Spaghetti: Web Application Security Scanner
#
# @url: https://github.com/m4ll0k/Spaghetti
# @author: Momo Outaadi (M4ll0k)
# @license: See the file 'doc/LICENSE'

import airlock
import anquanboa
import aws
import baidu
import barracuda
import bigip
import binarysec
import blockdos
import chinacache
import ciscoacexml
import cloudflare
import cloudfront
import dotdefender
import edgecast
import fortiweb
import hyperguard
import incapsula
import isaserver
import modsecurity
import netcontinuum
import paloalto
import profense
import radware
import requestvalidationmode
import safedog
import secureiis
import sengnix
import sitelock
import sonicwall
import sucuri
import trafficshield
import urlscan
import varnish
import wallarm
import webknight

def Waf(headers,content):
	return (
		airlock.Airlock().run(headers),
		anquanboa.Anquanboa().run(headers),
		aws.Aws().run(headers),
		baidu.Baidu().run(headers),
		barracuda.Barracuda().run(headers),
		bigip.Bigip().run(headers),
		binarysec.Binarysec().run(headers),
		blockdos.Blockdos().run(headers),
		chinacache.Chinacache().run(headers),
		ciscoacexml.Ciscoacexml().run(headers),
		cloudflare.Cloudflare().run(headers),
		cloudfront.Cloudfront().run(headers),
		dotdefender.Dotdefender().run(headers),
		edgecast.Edgecast().run(headers),
		fortiweb.Fortiweb().run(headers),
		hyperguard.Hyperguard().run(headers),
		incapsula.Incapsula().run(headers),
		isaserver.Isaserver().run(content),
		modsecurity.Modsecurity().run(headers),
		netcontinuum.Netcontinuum().run(headers),
		paloalto.Paloalto().run(headers),
		profense.Profense().run(headers),
		radware.Radware().run(headers),
		requestvalidationmode.Requestvalidationmode().run(content),
		safedog.Safedog().run(headers),
		secureiis.Secureiis().run(content),
		sengnix.Senginx().run(content),
		sitelock.Sitelock().run(content),
		sonicwall.Sonicwall().run(content),
		sucuri.Sucuri().run(headers),
		trafficshield.Trafficshield().run(headers),
		urlscan.Urlscan().run(headers),
		varnish.Varnish().run(headers),
		wallarm.Wallarm().run(headers),
		webknight.Webknight().run(headers)
		)		