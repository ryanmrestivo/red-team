
import logging
import asyncio


from asysocks import logger
from asysocks._version import __banner__
from asysocks.client import SOCKSClient
from asysocks.common.clienturl import SocksClientURL
from asysocks.common.comms import SocksLitenerComms

def main():
	import argparse

	parser = argparse.ArgumentParser(description='Transparent TCP tunnel for SOCKS unaware clients.')
	parser.add_argument('proxy_connection_string', help='connection string decribing the socks5 proxy server connection properties')
	parser.add_argument('dst_ip', help='IP address of the desination server')
	parser.add_argument('dst_port', type = int, help='port number of the desination service')
	parser.add_argument('-l', '--listen-ip', default = '127.0.0.1',  help='Listener IP address to bind to')
	parser.add_argument('-p', '--listen-port', type = int, default = 11111, help='Listener port number to bind to')
	parser.add_argument('-t', '--timeout', type = int, default = None, help='Endpoint timeout')
	parser.add_argument('-v', '--verbose', action='count', default=0)

	args = parser.parse_args()

	if args.verbose >=1:
		logger.setLevel(logging.DEBUG)
		

	elif args.verbose > 2:
		logger.setLevel(1)

	comms = SocksLitenerComms(args.listen_ip, args.listen_port)

	url = SocksClientURL.from_url(args.proxy_connection_string)
	url.endpoint_ip = args.dst_ip
	url.endpoint_port = args.dst_port
	url.endpoint_timeout = args.timeout

	target = url.get_target()
	credentials = url.get_creds()

	if args.verbose >=1:
		print(str(target))

	print(__banner__)
	layout = """Connection layout
	
	CLIENT --->|
	CLIENT --->|(LISTENER) %s:%s  |--->| (%s) %s:%s |--->| (FINAL DST) %s:%s
	CLIENT --->|
	
	""" % (args.listen_ip, args.listen_port, target.version.name.upper() ,target.server_ip, target.server_port, args.dst_ip, args.dst_port)

	print(layout)

	client = SOCKSClient(comms, target, credentials)

	print('Waiting for incoming connections')
	asyncio.run(client.run())
	


if __name__ == '__main__':
	main()