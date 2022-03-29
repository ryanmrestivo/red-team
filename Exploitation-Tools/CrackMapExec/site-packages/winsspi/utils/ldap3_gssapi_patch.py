from minikerberos.sspi.kerberosspi import KerberosSSPI, SSPIResult
from ldap3.protocol.sasl.sasl import send_sasl_negotiation, abort_sasl_negotiation
import socket

def sasl_gssapi(connection, controls):
	print('MONKEY!')
	print(connection)
	print(controls)
	
	
	target_name = None
	authz_id = b""
	raw_creds = None
	creds = None
	if connection.sasl_credentials:
		if len(connection.sasl_credentials) >= 1 and connection.sasl_credentials[0]:
			if connection.sasl_credentials[0] is True:
				hostname = socket.gethostbyaddr(connection.socket.getpeername()[0])[0]
				target_name = 'ldap@' + hostname
			else:
				target_name = 'ldap@' + connection.sasl_credentials[0]
		if len(connection.sasl_credentials) >= 2 and connection.sasl_credentials[1]:
			authz_id = connection.sasl_credentials[1].encode("utf-8")
		if len(connection.sasl_credentials) >= 3 and connection.sasl_credentials[2]:
			raw_creds = connection.sasl_credentials[2]
	if target_name is None:
		target_name = 'ldap@' + connection.server.host

	print('target_name : %s' % target_name)
	print('authz_id : %s' % authz_id)
	print('raw_creds : %s' % raw_creds)
	
	target = 'ldap/WIN2019AD.test.corp'
	#target = target_name
	
	ksspi = KerberosSSPI(target)
	in_token = None
	res = None
	#while True:
	#result = send_sasl_negotiation(connection, controls, '')
	while res != SSPIResult.OK:
		res, out_token = ksspi.init_ctx(in_token)
		print(out_token)
		result = send_sasl_negotiation(connection, controls, out_token)
		in_token = result['saslCreds']
		print(in_token)
	