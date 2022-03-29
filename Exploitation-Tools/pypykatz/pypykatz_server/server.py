from multiprocessing import Queue
from pypykatz_server.server import *
from pypykatz_server.resultprocess import ResultProcessing
		

if __name__ == '__main__':

	import argparse
	import glob

	parser = argparse.ArgumentParser(description='PypyKatz server')
	
	subparsers = parser.add_subparsers(help = 'servertype')
	subparsers.required = True
	subparsers.dest = 'servertype'
	
	socket_group = subparsers.add_parser('socket', help='Get secrets from LSASS minidump file')
	socket_group.add_argument('-l', '--listen-ip', default = '0.0.0.0', help='IP address to listen on. Default 0.0.0.0')
	socket_group.add_argument('-p', '--listen-port', type=int, default = 54545, help = 'Port to listen on. Default 54545')
	socket_group.add_argument('-o', '--out-dir', default = 'creds', help = 'Directory to stroe credentials')
	socket_group.add_argument('-r', '--return-data', action='store_true', help = 'Return data to the client after sucsessul dump')
	
	args = parser.parse_args()
	
	resQ = Queue()
	r = ResultProcessing(resQ, args.out_dir)
	r.daemon = True
	r.start()
	print('[+] Starting server...')
	server = ThreadedPYPYSocketServer(args.listen_ip, args.listen_port, resQ, args.return_data)
	server.run()