WAFlulz is a work in progress starting with Web Application Firewall (WAF) recon, with plans to move on to mapping and exploitation. Currently only WAF detection functionality is included. Most regex's for detection modules came from the sqlmap source for --identify-waf option. Some additional plugins or modifications have been done.

WAFlulz includes a proxy randomization function, but you will need to populate the httpproxy and httpsproxy text files with your own selection of proxies using the format shown there. We do not endorse the proxies listed currently, these were just ones that were used for initial testing based on the HMA lists.

Additionally completely passive recon capabilities have been included to fingerprint WAFs without sending any traffic to them. Several User-Agent choices are also available to choose from, including mobile browsers.

Currently, normal, modsecurity and aggressive modes are enabled, however aggressive mode fingerprints are still a work in progress.

Python-Requests is REQUIRED for usage. Install with $ pip install requests or $ easy_install requests

Known Working Modules (9)
---------------------
Incapsula
Cloudflare
BigIP
Barracuda
Port80 ServerDefender Pro - *New*
Netscaler
Fortiweb - *Updated*
BinarySec
United Security Providers Secure Entry Server

Partially Working Modules (1)
-------------------------
ISA Server | TMG - *Updated*

Untested Modules (16)
----------------
ModSecurity
DenyAll 
Hyperguard 
Teros 
Webknight 
Datapower IBM 
Cisco ACE XML 
Netcontinuum | Barracuda 
Jiasule-WAF 
Profense 
TrafficShield
Radware
PaloAlto
Knownsec
DotDefender
Kona


Contributors
------------
David Bressler (bostonlink) helped me out a few times when I was struggling with some stupid errors. Thanks bro! Check out his work at https://github.com/bostonlink
