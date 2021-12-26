

from asysocks.common.constants import SocksCommsMode

class SocksComms:
	def __init__(self):
		self.mode = None

class SocksQueueComms(SocksComms):
	def __init__(self, in_queue, out_queue):
		super(SocksComms)
		self.mode = SocksCommsMode.QUEUE
		self.in_queue = in_queue
		self.out_queue = out_queue

class SocksLitenerComms(SocksComms):
	def __init__(self, listen_ip, listen_port):
		super(SocksComms)
		self.mode = SocksCommsMode.LISTENER
		self.listen_ip = listen_ip
		self.listen_port = listen_port