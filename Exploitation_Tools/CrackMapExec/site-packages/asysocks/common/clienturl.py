

from urllib.parse import urlparse, parse_qs
import ssl

from asysocks.common.credentials import SocksCredential
from asysocks.common.constants import SocksServerVersion, SocksProtocol, SOCKS5Method
from asysocks.common.target import SocksTarget

def stru(x):
	return str(x).upper()
	
clienturl_param2var = {
	'type' : ('version', [stru, SocksServerVersion]),
	'host' : ('server_ip', [str]),
	'server' : ('server_ip', [str]),
	'port' : ('server_port', [int]),
	'bind' : ('is_bind', [bool]),
	'proto': ('proto', [SocksProtocol]),
	'timeout': ('timeout', [int]),
	'etimeout' : ('endpoint_timeout', [int]),
	'bsize' : ('buffer_size', [int]),
	'user' : ('username', [str]),
	'pass' : ('password', [str]),
	'authtype' : ('authtype', [SOCKS5Method]),
	'userid' : ('userid', [str]),

}

clienturl_url2var = {
	'isbind' : ('is_bind', bool),
	'proto' : ('proto', SocksProtocol),
	'timeout' : ('timeout', int),
	'buffersize' : ('buffer_size', int),
	'userid' : ('userid', str),
}

sockssslversions = {
	SocksServerVersion.SOCKS5S : 1,
	SocksServerVersion.SOCKS4S : 1,
	SocksServerVersion.HTTPS : 1,
}

class SocksClientURL:
	def __init__(self):
		self.version = None
		self.server_ip = None
		self.server_port = 1080
		self.is_bind = False
		self.proto = SocksProtocol.TCP
		self.timeout = 10
		self.buffer_size = 4096
		self.ssl_ctx = None
		
		self.endpoint_ip = None
		self.endpoint_port = None
		self.endpoint_timeout = None
		
		self.username = None
		self.password = None


	def get_creds(self):
		if self.username is None:
			return None
		creds = SocksCredential()
		creds.username = self.username
		creds.password = self.password
		return creds

	def get_target(self):
		target = SocksTarget()
		target.version = self.version
		target.server_ip = self.server_ip
		target.server_port = self.server_port
		target.is_bind = self.is_bind
		target.proto = self.proto
		target.timeout = self.timeout
		target.buffer_size = self.buffer_size
		target.endpoint_ip = self.endpoint_ip
		target.endpoint_port = self.endpoint_port
		target.endpoint_timeout = self.endpoint_timeout
		target.ssl_ctx = self.ssl_ctx
		return target

	def sanity_check(self):
		if self.server_ip is None:
			raise Exception('SOCKS server IP is missing!')
		if self.server_port is None:
			raise Exception('SOCKS server port is missing!')
		if self.buffer_size <= 0:
			raise Exception('buffer_size is too low! %s' % self.buffer_size)
		if self.endpoint_ip is None:
			raise Exception('Endpoint IP address is missing!')
		#if self.endpoint_port is None:
		#	raise Exception('Endpoint port is missing!')

	
	@staticmethod
	def from_url(url_str):
		# socks5://user:pass@ip:port/?

		res = SocksClientURL()
		url_e = urlparse(url_str)

		res.version = SocksServerVersion(url_e.scheme.upper())
		res.server_ip = url_e.hostname
		if url_e.port is not None:
			res.server_port = int(url_e.port)
		elif res.version == SocksServerVersion.HTTP:
			res.server_port = 8080
		elif res.version == SocksServerVersion.HTTPS:
			res.server_port = 8443
		elif res.version == SocksServerVersion.SOCKS5:
			res.server_port = 1080
		elif res.version == SocksServerVersion.SOCKS5S:
			res.server_port = 1080
		elif res.version == SocksServerVersion.SOCKS4:
			res.server_port = 1080
		elif res.version == SocksServerVersion.SOCKS4S:
			res.server_port = 1080
		res.username = url_e.username
		res.password = url_e.password
		if res.version in sockssslversions:
			res.ssl_ctx = ssl.create_default_context()

		if url_e.query is not None:
			query = parse_qs(url_e.query)
			for k in query:
				if k in clienturl_url2var:
					pname = clienturl_url2var[k][0]
					param = clienturl_url2var[k][1](query[k][0])
					setattr(res, pname, param)
		
		return res

	@staticmethod
	def from_params(url_str):
		"""

		"""
		res = SocksClientURL()
		url = urlparse(url_str)
		res.endpoint_ip = url.hostname
		if url.port:
			res.endpoint_port = int(url.port)
		if url.query is not None:
			query = parse_qs(url.query)

			for k in query:
				if k.startswith('proxy'):
					if k[5:] in clienturl_param2var:

						data = query[k][0]
						for c in clienturl_param2var[k[5:]][1]:
							#print(c)
							data = c(data)

						setattr(
							res, 
							clienturl_param2var[k[5:]][0], 
							data
						)
		
		if res.version in sockssslversions:
			res.ssl_ctx = ssl.create_default_context()

		res.sanity_check()
		

		return res





						