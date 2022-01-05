
from pypykatz_server.protocol.command import *

class SocketTransport:
	def __init__(self, soc):
		self.soc = soc
		
	def recv(self):
		total_len = -1
		data = b''
		while True:
			temp = self.soc.recv(1024)
			if temp == '':
				break
			
			data += temp
			
			if total_len == -1:
				if len(data) >= 4:
					total_len = int.from_bytes(data[:4], 'big', signed = False)
				else:
					continue
			
			if len(data) >= total_len+4:
				break
	
		if data == b'':
			raise Exception('Client terminated the connection')
		cmd = PYPYCMD.from_bytes(data[4:])
		#print(str(cmd))
		return cmd
		
	def send(self, cmd):
		data = cmd.to_bytes()
		self.soc.sendall(len(data).to_bytes(4, 'big', signed = False) +  data)
		
	def recvOK(self):
		cmd = self.recv()
		if cmd.cmdtype != PYPYCMDType.OK:
			raise Exception('OK expected! got :%s' % cmd.cmdtype.name)
		return cmd