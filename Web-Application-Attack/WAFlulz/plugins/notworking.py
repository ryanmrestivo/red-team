#!/usr/bin/env python
from signatures import *
import requests

colorred = "\033[01;31m{0}\033[00m"
'''
PLUGINS KNOWN NOT TO WORK
-------------------------
'''
#SecureIIS (BeyondTrust)
#prodName = denyall.fingerprint(r)
#if prodName is not None:
#	print ('The WAF detected was ' + str(prodName))

#WebAppSecure (Webscurity)
#prodName = webappsecure.fingerprint(r)
#if prodName is not None:
#	print ('The WAF detected was ' + str(prodName))



'''
PLUGINS NOT YET CREATED
-----------------------
'''
#Varnish https://www.owasp.org/index.php/OWASP_VFW_Project
#Ironbee https://www.ironbee.com/
#NAXSI https://www.owasp.org/index.php/OWASP_NAXSI_Project
#WebDefend (Trustwave) https://www.trustwave.com/web-application-firewall/
#URLscan http://www.iis.net/downloads/microsoft/urlscan
#SingleKey (Bayshore networks) http://bayshorenetworks.com/singlekey-ia-firewall.php
#Beeware iSuite http://www.bee-ware.net/en/products/i-suite-platform
#bugsec WebSniper http://www.bugsec.com/index.php?q=WebSniper
#ForumSentry http://www.forumsys.com/products/web_application_firewall_next_gen.php
#ThreatSentry (privacyware) http://www.privacyware.com/intrusion_prevention.html
#DefianceSS (protegrity) http://www.protegrity.com/2008/09/defiance-security-software-suite-4-5-released/
