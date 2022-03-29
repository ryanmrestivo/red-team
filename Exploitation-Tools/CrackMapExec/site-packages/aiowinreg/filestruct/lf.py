
"""

The "lf"-record
===============

Offset	Size	Contents
0x0000	Word	ID: ASCII-"lf" = 0x666C
0x0002	Word	number of keys
0x0004	????	Hash-Records

"""
import io
from aiowinreg.filestruct.hashrecord import NTRegistryHR

class NTRegistryLF:
	def __init__(self):
		self.magic = b'lf'
		self.keys_cnt = None
		self.hash_records = []
		
		
	def get_key_offsets(self, key_name):
		"""
		Checks all hash-records for match with key_name,
		if there is a match it returns the offset to the key (located in the hash record)
		if no match, it returns None
		"""
		offsets = []
		for hr in self.hash_records:
			if hr.hash_data.strip(b'\x00') == key_name.encode('ascii')[:4]:
				offsets.append(hr.offset_nk)
				
		return offsets
		
		
	@staticmethod
	def from_bytes(data):
		return NTRegistryLF.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		lf = NTRegistryLF()
		lf.magic = buff.read(2)
		lf.keys_cnt = int.from_bytes(buff.read(2), 'little', signed = False)
		for _ in range(lf.keys_cnt):
			hr = NTRegistryHR.from_buffer(buff)
			lf.hash_records.append(hr)
		return lf
		
	def __str__(self):
		t = '== NT Registry LF Record ==\r\n'
		for k in self.__dict__:
			if isinstance(self.__dict__[k], list):
				for i, item in enumerate(self.__dict__[k]):
					t += '   %s: %s: %s' % (k, i, str(item))
			else:
				t += '%s: %s \r\n' % (k, str(self.__dict__[k]))
		return t