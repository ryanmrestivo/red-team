
"""

The "lf"-record
===============

Offset	Size	Contents
0x0000	Word	ID: ASCII-"lf" = 0x666C
0x0002	Word	number of keys
0x0004	????	Hash-Records

"""
import io

class NTRegistryRI:
	def __init__(self):
		self.magic = b'ri'
		self.keys_cnt = None
		self.hash_records = []
		
	@staticmethod
	def from_bytes(data):
		return NTRegistryRI.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		lf = NTRegistryRI()
		lf.magic = buff.read(2)
		lf.keys_cnt = int.from_bytes(buff.read(2), 'little', signed = False)
		for _ in lf.keys_cnt:
			hr = NTRegistryHR.from_buffer(buff)
			lf.hash_records.append(hr)
		return lf
		
	def __str__(self):
		t = '== NT Registry RI Record ==\r\n'
		for k in self.__dict__:
			if isinstance(self.__dict__[k], list):
				for i, item in enumerate(self.__dict__[k]):
					t += '   %s: %s: %s' % (k, i, str(item))
			else:
				t += '%s: %s \r\n' % (k, str(self.__dict__[k]))
		return t