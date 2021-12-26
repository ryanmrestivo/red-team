
from urllib.parse import urlparse, parse_qs
from asysocks.common.constants import SocksServerVersion, SocksProtocol


class SocksTarget:
	def __init__(self):
		self.version = None
		self.server_ip = None
		self.server_port = None
		self.is_bind = False
		self.proto = SocksProtocol.TCP
		self.timeout = 10 #used to create the connection
		self.buffer_size = 4096
		self.ssl_ctx = None
		
		self.endpoint_ip = None
		self.endpoint_port = None
		self.endpoint_timeout = None #used after the connection is made

		self.only_open = False #These params used for security testing only! 
		self.only_auth = False #These params used for security testing only!
		self.only_bind = False #These params used for security testing only!
		

	def __repr__(self):
		return str(self.__dict__)

	def __str__(self):
		return repr(self)
