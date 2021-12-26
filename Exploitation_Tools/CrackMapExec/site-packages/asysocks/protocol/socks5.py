#https://www.ietf.org/rfc/rfc1928.txt
#https://tools.ietf.org/html/rfc1929
#https://tools.ietf.org/html/rfc1961

import io
import enum
import ipaddress
import socket
import asyncio

from asysocks.common.aiowrappers import read_or_exc
from asysocks.common.constants import SOCKS5Method 


class SOCKS5ServerState(enum.Enum):
	NEGOTIATION = 0
	NOT_AUTHENTICATED = 1
	REQUEST = 3 
	RELAYING = 4


class SOCKS5Command(enum.Enum):
	CONNECT = 0x01
	BIND = 0x02
	UDP_ASSOCIATE = 0x03


class SOCKS5AddressType(enum.Enum):
	IP_V4 = 0x01
	DOMAINNAME = 0x03
	IP_V6 = 0x04


class SOCKS5ReplyType(enum.Enum):
	SUCCEEDED = 0x00 # o  X'00' succeeded
	FAILURE = 0x01 # o  X'01' general SOCKS server failure
	CONN_NOT_ALLOWED = 0x02 #         o  X'02' connection not allowed by ruleset
	NETWORK_UNREACHABLE = 0x03 #o  X'03' Network unreachable
	HOST_UNREACHABLE = 0x04 #o  X'04' Host unreachable
	CONN_REFUSED = 0x05 #o  X'05' Connection refused
	TTL_EXPIRED = 0x06 #o  X'06' TTL expired
	COMMAND_NOT_SUPPORTED = 0x07 #o  X'07' Command not supported
	ADDRESS_TYPE_NOT_SUPPORTED = 0x08 #o  X'08' Address type not supported
	#o  X'09' to X'FF' unassigned

class SOCKS5ServerErrorReply(Exception):
	def __init__(self, reply):
		self.reply = reply
	def __str__(self):
		return self.reply.name

class SOCKS5AuthFailed(Exception):
	pass

class SOCKS5SocketParser:
	def __init__(self, protocol = socket.SOCK_STREAM):
		self.protocol = protocol

	def parse(self, soc, packet_type):
		return packet_type.from_bytes(self.read_soc(soc, packet_type.size))

	def read_soc(self, soc, size):
		data = b''
		while True:
			temp = soc.recv(4096)
			if temp == '':
				break
			data += temp
			if len(data) == size:
				break
		return data


class SOCKS5CommandParser:
	# the reason we need this class is: SOCKS5 protocol messages doesn't have a type field,
	# the messages are parsed in context of the session itself.
	def __init__(self, protocol = socket.SOCK_STREAM):
		self.protocol = protocol #not used atm

	def parse(self, buff, session):
		if session.current_state == SOCKS5ServerState.NEGOTIATION:
			return SOCKS5Nego.from_buffer(buff)
		
		if session.current_state == SOCKS5ServerState.NOT_AUTHENTICATED:
			if session.mutual_auth_type == SOCKS5Method.PLAIN:
				return SOCKS5PlainAuth.from_buffer(buff)
			else:
				raise Exception('Not implemented!')

		if session.current_state == SOCKS5ServerState.REQUEST:
			return SOCKS5Request.from_buffer(buff)

	@staticmethod
	async def from_streamreader(reader, session, timeout = None):
		raise NotImplementedError()
		#if session.current_state == SOCKS5ServerState.NEGOTIATION:
		#	t = await asyncio.wait_for(SOCKS5Nego.from_streamreader(reader), timeout = timeout)
		#	return t
		#
		#if session.current_state == SOCKS5ServerState.NOT_AUTHENTICATED:
		#	if session.mutual_auth_type == SOCKS5Method.PLAIN:
		#		t = await asyncio.wait_for(SOCKS5PlainAuth.from_streamreader(reader), timeout = timeout)
		#		return t
		#	else:
		#		raise Exception('Not implemented!')
		#
		#if session.current_state == SOCKS5ServerState.REQUEST:
		#	t = await asyncio.wait_for(SOCKS5Request.from_streamreader(reader), timeout = timeout)
		#	return t


class SOCKS5AuthHandler:
	def __init__(self, authtype, creds = None):
		self.authtype  = authtype
		self.creds = creds

	def do_AUTH(self, msg):
		if self.authtype == SOCKS5Method.PLAIN:
			if not isinstance(msg, SOCKS5PlainAuth):
				raise Exception('Wrong message/auth type!')

			if self.creds is None:
				return True, SOCKS5PlainCredentials(msg.UNAME, msg.PASSWD)
			else:
				if msg.UNAME in self.creds:
					if msg.PASSWD == self.creds[msg.UNAME]:
						return True, SOCKS5PlainCredentials(msg.UNAME, msg.PASSWD)

				return False, SOCKS5PlainCredentials(msg.UNAME, msg.PASSWD)

		elif self.authtype == SOCKS5Method.GSSAPI:
			raise Exception('Not implemented! yet')
		
		else:
			raise Exception('Not implemented!')


class SOCKS5PlainCredentials:
	def __init__(self, username, password):
		self.username = username
		self.password = password

class SOCKS5PlainAuthReply:
	def __init__(self):
		self.VER = None
		self.STATUS = None

	@staticmethod
	async def from_streamreader(reader):
		rep = SOCKS5PlainAuthReply()
		t = await reader.read(1)
		rep.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.read(1)
		rep.STATUS = SOCKS5ReplyType(int.from_bytes(t, byteorder = 'big', signed = False))

		return rep

	@staticmethod
	def from_bytes(data):
		return SOCKS5PlainAuthReply.from_buffer(io.BytesIO(data))
	
	@staticmethod
	def from_buffer(buff):
		rep = SOCKS5PlainAuthReply()
		rep.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		rep.STATUS = SOCKS5ReplyType(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		return rep 

class SOCKS5PlainAuth:
	def __init__(self):
		self.VER = None
		self.ULEN = None
		self.UNAME = None
		self.PLEN = None
		self.PASSWD = None

	@staticmethod
	async def from_streamreader(reader):
		auth = SOCKS5PlainAuth()
		t = await reader.read(1)
		auth.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.read(1)
		auth.ULEN = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.read(auth.ULEN)
		auth.UNAME = t.decode()
		t = await reader.read(1)
		auth.PLEN = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.read(auth.PLEN)
		auth.PASSWD = t.decode()

		return auth

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5PlainAuth.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		auth = SOCKS5PlainAuth()
		auth.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
		auth.ULEN = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		auth.UNAME = buff.read(auth.ULEN).decode()
		auth.PLEN = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		auth.PASSWD = buff.read(auth.PLEN).decode()

		return auth

	@staticmethod
	def construct(username, password):
		auth = SOCKS5PlainAuth()
		auth.VER    = 1
		auth.ULEN   = len(username)
		auth.UNAME  = username
		auth.PLEN   = len(password)
		auth.PASSWD = password

		return auth

	def to_bytes(self):
		t  = self.VER.to_bytes(1, byteorder = 'big', signed = False)
		t += self.ULEN.to_bytes(1, byteorder = 'big', signed = False)
		t += self.UNAME.encode()
		t += self.PLEN.to_bytes(1, byteorder = 'big', signed = False)
		t += self.PASSWD.encode()
		return t


class SOCKS5Nego:
	def __init__(self):
		self.VER = 5
		self.NMETHODS = None
		self.METHODS = None

	@staticmethod
	async def from_streamreader(reader):
		nego = SOCKS5Nego()
		t = await reader.readexactly(1)
		nego.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		nego.NMETHODS = int.from_bytes(t, byteorder = 'big', signed = False)
		nego.METHODS = []
		for _ in range(nego.NMETHODS):
			t = await reader.readexactly(1)
			nego.METHODS.append(SOCKS5Method(int.from_bytes(t, byteorder = 'big', signed = False)))

		return nego

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5Nego.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		nego = SOCKS5Nego()
		nego.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
		nego.NMETHODS = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
		nego.METHODS = []
		for _ in range(nego.NMETHODS):
			nego.METHODS.append(SOCKS5Method(int.from_bytes(buff.read(1), byteorder = 'big', signed = False)))
		return nego

	@staticmethod
	def from_methods(methods):
		if not isinstance(methods, list):
			methods = [methods]
		nego = SOCKS5Nego()
		nego.NMETHODS = len(methods)
		nego.METHODS = methods
		return nego

	def to_bytes(self):
		t  = self.VER.to_bytes(1, byteorder = 'big', signed = False)
		t += self.NMETHODS.to_bytes(1, byteorder = 'big', signed = False)
		for method in self.METHODS:
			t += method.value.to_bytes(1, byteorder = 'big', signed = False)
		return t

class SOCKS5NegoReply:
	def __init__(self):
		self.VER = 5
		self.METHOD = None

	def __repr__(self):
		t  = '== SOCKS5NegoReply ==\r\n'
		t += 'VER: %s\r\n' % self.VER
		t += 'METHOD: %s\r\n' % self.METHOD
		return t

	@staticmethod
	def from_socket(soc):
		data = b''
		total_size = 2
		while True:
			temp = soc.recv(1024)
			if temp == b'':
				break
			data += temp
			if len(data) >= total_size:
				break
		print(data)
		return SOCKS5NegoReply.from_bytes(data)

	@staticmethod
	async def from_streamreader(reader):
		rep = SOCKS5NegoReply()
		t = await reader.readexactly(1)
		rep.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		rep.METHOD = SOCKS5Method(int.from_bytes(t, byteorder = 'big', signed = False))
		
		return rep

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5NegoReply.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		rep = SOCKS5NegoReply()
		rep.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		rep.METHOD = SOCKS5Method(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		return rep

	@staticmethod
	def construct(method):
		rep = SOCKS5NegoReply()
		rep.VER = 5
		rep.METHOD = method
		return rep

	@staticmethod
	def construct_auth(method, ver = 1):
		rep = SOCKS5NegoReply()
		rep.VER = ver
		rep.METHOD = method
		return rep


	def to_bytes(self):
		t  = self.VER.to_bytes(1, byteorder = 'big', signed = False)
		t += self.METHOD.value.to_bytes(1, byteorder = 'big', signed = False)
		return t


class SOCKS5Request:
	def __init__(self):
		self.VER = 5
		self.CMD = SOCKS5Command.CONNECT
		self.RSV = 0
		self.ATYP = None
		self.DST_ADDR = None
		self.DST_PORT = None

	@staticmethod
	async def from_streamreader(reader):
		req = SOCKS5Request()
		t = await reader.readexactly(1)
		req.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		req.CMD = SOCKS5Command(int.from_bytes(t, byteorder = 'big', signed = False))
		t = await reader.readexactly(1)
		req.RSV = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		req.ATYP = SOCKS5AddressType(int.from_bytes(t, byteorder = 'big', signed = False))
		if req.ATYP == SOCKS5AddressType.IP_V4:
			t = await reader.readexactly(4)
			req.DST_ADDR = ipaddress.IPv4Address(t)
		elif req.ATYP == SOCKS5AddressType.IP_V6:
			t = await reader.readexactly(16)
			req.DST_ADDR = ipaddress.IPv6Address(t)

		elif req.ATYP == SOCKS5AddressType.DOMAINNAME:
			t = await reader.readexactly(1)
			length = int.from_bytes(t, byteorder = 'big', signed = False)
			t = await reader.readexactly(length)
			req.DST_ADDR = t.decode()

		t = await reader.readexactly(2)
		req.DST_PORT = int.from_bytes(t, byteorder = 'big', signed = False)

		return req

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5Request.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		req = SOCKS5Request()
		req.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		req.CMD = SOCKS5Command(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		req.RSV = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
		req.ATYP = SOCKS5AddressType(int.from_bytes(buff.read(1), byteorder = 'big', signed = False)) 
		if req.ATYP == SOCKS5AddressType.IP_V4:
			req.DST_ADDR = ipaddress.IPv4Address(buff.read(4))
		elif req.ATYP == SOCKS5AddressType.IP_V6:
			req.DST_ADDR = ipaddress.IPv6Address(buff.read(16))
		elif req.ATYP == SOCKS5AddressType.DOMAINNAME:
			length = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
			req.DST_ADDR = buff.read(length).decode()

		req.DST_PORT = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)
		return req

	@staticmethod
	def from_target(target):
		req = SOCKS5Request()
		req.CMD = SOCKS5Command.CONNECT
		if target.is_bind is True:
			req.CMD = SOCKS5Command.BIND
		
		if isinstance(target.endpoint_ip, ipaddress.IPv4Address):
			req.ATYP = SOCKS5AddressType.IP_V4
			req.DST_ADDR = target.endpoint_ip
		elif isinstance(target.endpoint_ip, ipaddress.IPv6Address):
			req.ATYP = SOCKS5AddressType.IP_V6
			req.DST_ADDR = target.endpoint_ip
		elif isinstance(target.endpoint_ip, str):
			req.ATYP = SOCKS5AddressType.DOMAINNAME
			req.DST_ADDR = target.endpoint_ip

		req.DST_PORT = target.endpoint_port
		return req

	@staticmethod
	def construct(cmd, address, port):
		req = SOCKS5Request()
		req.VER = 5
		req.CMD = cmd
		req.RSV = 0
		if isinstance(address, ipaddress.IPv4Address):
			req.ATYP = SOCKS5AddressType.IP_V4
			req.DST_ADDR = address
		elif isinstance(address, ipaddress.IPv6Address):
			req.ATYP = SOCKS5AddressType.IP_V6
			req.DST_ADDR = address
		elif isinstance(address, str):
			req.ATYP = SOCKS5AddressType.DOMAINNAME
			req.DST_ADDR = address

		req.DST_PORT = port
		return req

	def to_bytes(self):
		t  = self.VER.to_bytes(1, byteorder = 'big', signed = False)
		t += self.CMD.value.to_bytes(1, byteorder = 'big', signed = False)
		t += self.RSV.to_bytes(1, byteorder = 'big', signed = False)
		t += self.ATYP.value.to_bytes(1, byteorder = 'big', signed = False)
		if self.ATYP == SOCKS5AddressType.DOMAINNAME:
			t += len(self.DST_ADDR).to_bytes(1, byteorder = 'big', signed = False)
			t += self.DST_ADDR.encode()
		else:	
			t += self.DST_ADDR.packed
		t += self.DST_PORT.to_bytes(2, byteorder = 'big', signed = False)
		return t


class SOCKS5Reply:
	def __init__(self):
		self.VER = None
		self.REP = None
		self.RSV = None
		self.ATYP = None
		self.BIND_ADDR= None
		self.BIND_PORT= None

	@staticmethod
	def from_socket(soc):
		data = b''
		total_size = 1024
		while True:
			temp = soc.recv(1024)
			if temp == b'':
				break
			data += temp

			if len(data) > 4:
				rt = SOCKS5AddressType(data[3])
				print(rt)
				if rt == SOCKS5AddressType.IP_V4:
					total_size = 4 + 2 + 4
				if rt == SOCKS5AddressType.IP_V6:
					total_size = 4 + 2 + 16
				if rt == SOCKS5AddressType.DOMAINNAME:
					total_size = 4 + 2 + data[4]
				print(total_size)
			if len(data) >= total_size:
				break

		return SOCKS5Reply.from_bytes(data)

	@staticmethod
	async def from_streamreader(reader):
		rep = SOCKS5Reply()
		t = await reader.readexactly(1)
		rep.VER = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		rep.REP = SOCKS5ReplyType(int.from_bytes(t, byteorder = 'big', signed = False))
		t = await reader.readexactly(1)
		rep.RSV = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		rep.ATYP = SOCKS5AddressType(int.from_bytes(t, byteorder = 'big', signed = False))
		if rep.ATYP == SOCKS5AddressType.IP_V4:
			t = await reader.readexactly(4)
			rep.BIND_ADDR = ipaddress.IPv4Address(t)
		elif rep.ATYP == SOCKS5AddressType.IP_V6:
			t = await reader.readexactly(16)
			rep.BIND_ADDR = ipaddress.IPv6Address(t)
		elif rep.ATYP == SOCKS5AddressType.DOMAINNAME:
			t = await reader.readexactly(1)
			length = int.from_bytes(t, byteorder = 'big', signed = False)
			t = await reader.readexactly(length)
			rep.BIND_ADDR = t.decode()

		t = await reader.readexactly(2)
		rep.BIND_PORT = int.from_bytes(t, byteorder = 'big', signed = False)
		return rep

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5Reply.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		rep = SOCKS5Reply()
		rep.VER = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
		rep.REP = SOCKS5ReplyType(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		rep.RSV = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		rep.ATYP = SOCKS5AddressType(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))

		if rep.ATYP == SOCKS5AddressType.IP_V4:
			rep.BIND_ADDR = ipaddress.IPv4Address(buff.read(4))
		elif rep.ATYP == SOCKS5AddressType.IP_V6:
			rep.BIND_ADDR = ipaddress.IPv6Address(buff.read(16))
		elif rep.ATYP == SOCKS5AddressType.DOMAINNAME:
			length = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
			rep.BIND_ADDR = buff.read(length).decode()

		rep.BIND_PORT = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)

		return rep

	@staticmethod
	def construct(reply, address, port): 
		rep = SOCKS5Reply()
		rep.VER = 5
		rep.REP = reply
		rep.RSV = 0
		if isinstance(address, ipaddress.IPv4Address):
			rep.ATYP = SOCKS5AddressType.IP_V4
			rep.DST_ADDR = address
		elif isinstance(address, ipaddress.IPv6Address):
			rep.ATYP = SOCKS5AddressType.IP_V6
			rep.DST_ADDR = address
		elif isinstance(address, str):
			rep.ATYP = SOCKS5AddressType.DOMAINNAME
			rep.DST_ADDR = address

		rep.DST_PORT = port
		return rep

	def to_bytes(self):
		t  = self.VER.to_bytes(1, byteorder = 'big', signed = False)
		t += self.REP.value.to_bytes(1, byteorder = 'big', signed = False)
		t += self.RSV.to_bytes(1, byteorder = 'big', signed = False)
		t += self.ATYP.value.to_bytes(1, byteorder = 'big', signed = False)
		if self.ATYP == SOCKS5AddressType.DOMAINNAME:
			t += len(self.DST_ADDR).to_bytes(1, byteorder = 'big', signed = False)
			t += self.DST_ADDR.encode()
		else:	
			t += self.DST_ADDR.packed
		t += self.DST_PORT.to_bytes(2, byteorder = 'big', signed = False)
		return t

	def __repr__(self):
		t  = '== SOCKS5Reply ==\r\n'
		t += 'REP: %s\r\n' % repr(self.REP)
		t += 'ATYP: %s\r\n' % repr(self.ATYP)
		t += 'BIND_ADDR: %s\r\n' % repr(self.BIND_ADDR)
		t += 'BIND_PORT: %s\r\n' % repr(self.BIND_PORT)

		return t


class SOCKS5UDP:
	def __init__(self):
		self.RSV = None
		self.FRAG = None
		self.ATYP = None
		self.DST_ADDR = None
		self.DST_PORT = None
		self.DATA = None

	@staticmethod
	async def from_streamreader(reader):
		rep = SOCKS5UDP()
		t = await reader.readexactly(2)
		rep.RSV = int.from_bytes(t, byteorder = 'big', signed = False)
		t = await reader.readexactly(1)
		rep.FRAG = SOCKS5ReplyType(int.from_bytes(t, byteorder = 'big', signed = False))
		t = await reader.readexactly(1)
		rep.ATYP = SOCKS5AddressType(int.from_bytes(t, byteorder = 'big', signed = False))
		if rep.ATYP == SOCKS5AddressType.IP_V4:
			t = await reader.readexactly(4)
			rep.DST_ADDR = ipaddress.IPv4Address(t)
		elif rep.ATYP == SOCKS5AddressType.IP_V6:
			t = await reader.readexactly(16)
			rep.DST_ADDR = ipaddress.IPv6Address(t)

		elif rep.ATYP == SOCKS5AddressType.DOMAINNAME:
			t = await reader.readexactly(1)
			length = int.from_bytes(t, byteorder = 'big', signed = False)
			t = await reader.readexactly(length)
			rep.DST_ADDR = t.decode()

		t = await reader.readexactly(2)
		rep.DST_PORT = int.from_bytes(t, byteorder = 'big', signed = False)
		return rep

	@staticmethod
	def from_bytes(bbuff):
		return SOCKS5UDP.from_buffer(io.BytesIO(bbuff))

	@staticmethod
	def from_buffer(buff):
		rep = SOCKS5UDP()
		rep.RSV = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)
		rep.FRAG = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		rep.ATYP = SOCKS5AddressType(buff.read(1), byteorder = 'big', signed = False)
		if rep.ATYP == SOCKS5AddressType.IP_V4:
			rep.DST_ADDR = ipaddress.IPv4Address(buff.read(4))
		elif rep.ATYP == SOCKS5AddressType.IP_V6:
			rep.DST_ADDR = ipaddress.IPv6Address(buff.read(16))
		elif rep.ATYP == SOCKS5AddressType.DOMAINNAME:
			length = int.from_bytes(buff.read(1), byteorder = 'big', signed = False) 
			rep.DST_ADDR = buff.read(length).decode()

		rep.DST_PORT = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)
		#be careful, not data length is defined in the RFC!!
		rep.DATA = buff.read()

	@staticmethod
	def construct(address, port, data, frag = 0):
		req = SOCKS5Request()
		req.RSV = 0
		req.FRAG = frag
		if isinstance(address, ipaddress.IPv4Address):
			req.ATYP = SOCKS5AddressType.IP_V4
			req.DST_ADDR = address
		elif isinstance(address, ipaddress.IPv6Address):
			req.ATYP = SOCKS5AddressType.IP_V6
			req.DST_ADDR = address
		elif isinstance(address, str):
			req.ATYP = SOCKS5AddressType.DOMAINNAME
			req.DST_ADDR = address

		req.DST_PORT = port
		req.DATA = data
		return req

	def to_bytes(self):
		t  = self.RSV.to_bytes(2, byteorder = 'big', signed = False)
		t += self.FRAG.value.to_bytes(1, byteorder = 'big', signed = False)
		t += self.ATYP.value.to_bytes(1, byteorder = 'big', signed = False)
		if self.ATYP == SOCKS5AddressType.DOMAINNAME:
			t += len(self.DST_ADDR).to_bytes(1, byteorder = 'big', signed = False)
			t += self.DST_ADDR.encode()
		else:	
			t += self.DST_ADDR.packed
		t += self.DST_PORT.to_bytes(2, byteorder = 'big', signed = False)
		t += self.DATA
		return t