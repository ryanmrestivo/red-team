
import asyncio
import logging
import ssl
import traceback

from asysocks import logger
from asysocks._version import __banner__
from asysocks.security import SocksSecurity

def main():

	import argparse

	parser = argparse.ArgumentParser(description='SOCKS5 proxy security tester')
	parser.add_argument('host', help='')
	parser.add_argument('port', help='')
	parser.add_argument('-t', '--timeout', type = int, default = None, help='Timeout')
	parser.add_argument('-v', '--verbose', action='count', default=0, help='Verbosity')
	parser.add_argument('--ssl', action='store_true', help='SSL')
	parser.add_argument('-s', '--silent', action='store_true', help='SSL')

	parser.add_argument('--verify-host', help='Destination host to test proxy on')
	parser.add_argument('--verify-port', type = int, help='Destination port to test proxy on')
	parser.add_argument('--verify-send', help='Data to send to destination to test the proxy')
	parser.add_argument('--verify-recv', help='Data expected to be recieved from the destination via proxy')

	parser.add_argument('-u', '--username', help='Username for proxy auth')
	parser.add_argument('-p', '--password', help='Password for proxy auth')

	args = parser.parse_args()

	if args.silent is False:
		print(__banner__)

	logger.setLevel(100)
	if args.verbose >=1:
		logger.setLevel(logging.DEBUG)
		

	elif args.verbose > 2:
		logger.setLevel(1)

	socsec = SocksSecurity()
	socsec.server_ip = args.host
	socsec.server_port = args.port
	socsec.server_sslctx = None if args.ssl is False else ssl.create_default_context()
	socsec.timeout = args.timeout
	socsec.verify_host = args.verify_host #endpoint ip/hostname to test the connection
	socsec.verify_port = args.verify_port #endpoint port
	socsec.verify_send = args.verify_send #data to be sent to the endpoint service upon succsessfull connection
	socsec.verify_recv = args.verify_recv #data expected from the endpoint service in response to verify_send


	supported, notsupported, errors = asyncio.run(socsec.socks5_authmethods())
	
	for method, err in errors:
		print('[AUTHMETHOD][E] %s : %s' % (method.name, err))
	
	for method in supported:
		print('[AUTHMETHOD][+] %s' % method.name)
	
	for method in notsupported:
		print('[AUTHMETHOD][-] %s' % method.name)


	res, err = asyncio.run(socsec.socks5_noauth())

	if err is not None:
		print('[NOAUTH][E] Error while determining noauth. Reson: %s' % err)
	elif res is True:
		print('[NOAUTH][+] No authentication needed')
	elif res is False:
		print('[NOAUTH][-] Authentication needed')
	
	
	res, err = asyncio.run(socsec.socks5_bind(args.username, args.password))
	if err is not None:
		print('[BIND][E] Error while determining BIND support. Reson: %s' % err)
	elif res is True:
		print('[BIND][+] Server supports BIND')
	elif res is False:
		print('[BIND][-] Server doesnt support BIND')

	res, err = asyncio.run(socsec.socks5_local(args.username, args.password))
	if err is not None:
		print('[LOCALPORT][E] Error while determining local connect support. Reson: %s' % err)
	elif res is True:
		print('[LOCALPORT][+] Server supports connecting to localhost')
	elif res is False:
		print('[LOCALPORT][-] Server doesnt support connecting to localhost')
	
	if args.verify_host is not None and args.verify_port is not None:
		if args.username is not None:
			res, err = asyncio.run(socsec.socks5_login(args.username, args.password))
		else:
			res, err = asyncio.run(socsec.socks5_noauth())

		if err is not None:
			print('[CONNTEST][E] Error while performing connection test! Reason: %s' % err)
		elif res is True:
			print('[CONNTEST][+] Server sucsessfully connected to %s:%s' % (args.verify_host, args.verify_port))
		elif res is False:
			print('[CONNTEST][-] Server failed to connect to %s:%s' % (args.verify_host, args.verify_port))


	if args.silent is False:
		print('Done!')

if __name__ == '__main__':
	main()