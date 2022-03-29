
# https://ftp.icm.edu.pl/packages/socks/socks4/SOCKS4.protocol

import io
import os
import enum
import ipaddress
import socket
import asyncio
from asysocks.common.aiowrappers import readuntil_or_exc, readexactly_or_exc

SOCKS4_USERID_MAC_LEN = 255

class SOCKS4CDCode(enum.Enum):
	REQ_CONNECT = 1
	REQ_BIND = 2

	REP_GRANTED = 90 #request granted
	REP_FAILED = 91 #request rejected or failed
	REP_FAILED_NOCONN = 92 #request rejected becasue SOCKS server cannot connect to identd on the client
	REP_FAILED_USRID_MISMATCH = 93 #request rejected because the client program and identd report different user-ids

class SOCKS4Request:
	def __init__(self):
		self.VN = 4
		self.CD = SOCKS4CDCode.REQ_CONNECT
		self.DSTPORT = None
		self.DSTIP = None
		self.USERID = None
	
	@staticmethod
	def from_bytes(data):
		return SOCKS4Request.from_buffer(io.BytesIO(data))

	@staticmethod
	async def from_streamreader(reader, timeout = None):
		try:
			t = await asyncio.wait_for(reader.readuntil(b'\x00'), timeout = timeout)
			return SOCKS4Request.from_bytes(t), None
		except Exception as e:
			return None, e

	@staticmethod
	def from_buffer(buff):
		o = SOCKS4Request()
		o.VN = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		o.CD = SOCKS4CDCode(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		o.DSTPORT = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)
		o.DSTIP = ipaddress.IPv4Address(buff.read(4))
		o.USERID = ''
		for _ in range(SOCKS4_USERID_MAC_LEN):
			x = buff.read(1)
			if x == 0:
				break
			o.USERID += x
		return o

	@staticmethod
	def from_target(target):
		o = SOCKS4Request()
		if target.is_bind is True:
			SOCKS4CDCode.REQ_BIND
		o.DSTPORT = target.endpoint_port
		if isinstance(target.endpoint_ip, ipaddress.IPv4Address):
			o.DSTIP = target.endpoint_ip
		else:
			o.DSTIP = ipaddress.ip_address(target.endpoint_ip)
		o.USERID = target.userid
		if target.userid is None:
			o.USERID = os.urandom(4).hex().encode('ascii')

		return o

	def to_bytes(self):
		t = self.VN.to_bytes(1, byteorder = 'big', signed = False)
		t += self.CD.value.to_bytes(1, byteorder = 'big', signed = False)
		t += self.DSTPORT.to_bytes(2, byteorder = 'big', signed = False)
		t += self.DSTIP.packed
		t += self.USERID
		t += b'\x00' #trailing for userid
		return t

class SOCKS4Reply:
	def __init__(self):
		self.VN = 0
		self.CD = None
		self.DSTPORT = None
		self.DSTIP = None

	@staticmethod
	def from_bytes(data):
		return SOCKS4Reply.from_buffer(io.BytesIO(data))

	@staticmethod
	async def from_streamreader(reader, timeout = None):
		try:
			t = await asyncio.wait_for(reader.readexactly(8), timeout = timeout)
			return SOCKS4Reply.from_bytes(t), None
		except Exception as e:
			return None, e

	@staticmethod
	def from_buffer(buff):
		o = SOCKS4Reply()
		o.VN = int.from_bytes(buff.read(1), byteorder = 'big', signed = False)
		o.CD = SOCKS4CDCode(int.from_bytes(buff.read(1), byteorder = 'big', signed = False))
		o.DSTPORT = int.from_bytes(buff.read(2), byteorder = 'big', signed = False)
		o.DSTIP = ipaddress.IPv4Address(buff.read(4))
		return o

	def to_bytes(self):
		t = self.VN.to_bytes(1, byteorder = 'big', signed = False)
		t += self.CD.value.to_bytes(1, byteorder = 'big', signed = False)
		t += self.DSTPORT.to_bytes(2, byteorder = 'big', signed = False)
		t += self.DSTIP.packed
		return t
