
# https://bazaar.launchpad.net/~guadalinex-members/dumphive/trunk/view/head:/winreg.txt
"""
0x00000000	D-Word	ID: ASCII-"regf" = 0x66676572
0x00000004	D-Word	????
0x00000008	D-Word	???? Always the same value as at 0x00000004
0x0000000C	Q-Word	last modify date in WinNT date-format
0x00000014	D-Word	1
0x00000018	D-Word	3
0x0000001C	D-Word	0
0x00000020	D-Word	1
0x00000024	D-Word	Offset of 1st key record
0x00000028	D-Word	Size of the data-blocks (Filesize-4kb)
0x0000002C	D-Word	1
0x000001FC	D-Word	Sum of all D-Words from 0x00000000 to 0x000001FB
"""
import io

class NTRegistryHeadr:
	def __init__(self):
		self.magic = b'regf'
		self.u1 = None
		self.u2 = None
		self.last_modified = None
		self.u3 = None
		self.u4 = None
		self.u5 = None
		self.u6 = None
		self.offset = None
		self.size = None
		self.u7 = None
		self.chksum = None

	def parse_header_bytes(self, data):
		self.parse_header_buffer(io.BytesIO(data))
	
	def parse_header_buffer(self, reader):
		self.magic = reader.read(4)
		self.u1 = reader.read(4)
		self.u2 = reader.read(4)
		self.last_modified = reader.read(8)
		self.u3 = int.from_bytes(reader.read(4), 'little', signed = False)
		self.u4 = int.from_bytes(reader.read(4), 'little', signed = False)
		self.u5 = int.from_bytes(reader.read(4), 'little', signed = False)
		self.u6 = int.from_bytes(reader.read(4), 'little', signed = False)
		self.offset = int.from_bytes(reader.read(4), 'little', signed = False)
		self.size = int.from_bytes(reader.read(4), 'little', signed = False)
		self.u7 = int.from_bytes(reader.read(4), 'little', signed = False)
		self.chksum = int.from_bytes(reader.read(4), 'little', signed = False)
	
	@staticmethod
	async def aread(reader):
		hdr = NTRegistryHeadr()
		data = await reader.read(52)
		hdr.parse_header_bytes(data)
		return hdr

	@staticmethod
	def read(reader):
		hdr = NTRegistryHeadr()
		hdr.parse_header_buffer(reader)
		return hdr

	def __str__(self):
		t = '== NT Registry header ==\r\n'
		for k in self.__dict__:
			t += '%s: %s \r\n' % (k, self.__dict__[k])
		return t