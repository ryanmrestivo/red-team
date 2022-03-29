import sys
import importlib
from ldap3 import Server, Connection, Tls, NTLM
from winsspi.sspi import LDAP3NTLMSSPI
import ldap3.utils.ntlm

#monkey-patching NTLM client with winsspi's implementation
ldap3.utils.ntlm.NtlmClient = LDAP3NTLMSSPI

#change server hostname to suit your environment
server = Server('WIN2019AD.test.corp', use_ssl=False)
c = Connection(server,user="doesntmatter\\doesntmatter", password="doesntmatter", authentication=NTLM)

if not c.bind():
	print('=== BIND result ====')
	print('BIND error! %s' % c.result)
else:
	print('=== BIND result ====')
	print('BIND succsess!!!')
	print(c.extend.standard.who_am_i())
