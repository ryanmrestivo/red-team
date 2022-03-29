

"""
the nk-Record
=============

Offset	Size	Contents
0x0000	Word	ID: ASCII-"nk" = 0x6B6E
0x0002	Word	for the root-key: 0x2C, otherwise 0x20
0x0004	Q-Word	write-date/time in windows nt notation
0x0010	D-Word	Offset of Owner/Parent key
0x0014	D-Word	number of sub-Keys
0x001C	D-Word	Offset of the sub-key lf-Records
0x0024	D-Word	number of values
0x0028	D-Word	Offset of the Value-List
0x002C	D-Word	Offset of the sk-Record
0x0030	D-Word	Offset of the Class-Name
0x0044	D-Word	Unused (data-trash)
0x0048	Word	name-length
0x004A	Word	class-name length
0x004C	????	key-name
"""
import io

class NTRegistrySK:
	def __init__(self):
		self.magic = b'sk'
		self.unknown = None
		self.offset_prev = None
		self.offset_next = None
		self.reference_cnt = None
		self.sd_size = None
		self.sd = None

	@staticmethod
	def from_bytes(data):
		return NTRegistrySK.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		sk = NTRegistrySK()
		sk.magic = buff.read(2)
		sk.unknown = int.from_bytes(buff.read(2), 'little', signed = False)
		sk.offset_prev = int.from_bytes(buff.read(4), 'little', signed = False)
		sk.offset_next = int.from_bytes(buff.read(4), 'little', signed = False)
		sk.reference_cnt = int.from_bytes(buff.read(4), 'little', signed = False)
		sk.sd_size = int.from_bytes(buff.read(4), 'little', signed = False)
		sk.sd = buff.read(sk.sd_size)
		return sk

	def __str__(self):
		t = '== NT Registry SK block ==\r\n'
		for k in self.__dict__:
			t += '%s: %s \r\n' % (k, self.__dict__[k])
		return t