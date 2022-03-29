
"""
Hash-Record
===========

Offset	Size	Contents
0x0000	D-Word	Offset of corresponding "nk"-Record
0x0004	D-Word	ASCII: the first 4 characters of the key-name, 
		padded with 0's. Case sensitiv!

Keep in mind, that the value at 0x0004 is used for checking the
data-consistency! If you change the key-name you have to change the
hash-value too!
"""
import io

class NTRegistryHR:
	def __init__(self):
		self.offset_nk = None
		self.hash_data = None
		
	@staticmethod
	def from_bytes(data):
		return NTRegistryHR.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		hr = NTRegistryHR()
		hr.offset_nk = int.from_bytes(buff.read(4), 'little', signed = False)
		hr.hash_data = buff.read(4)
		return hr
		
	def __str__(self):
		t = '== NT Registry HASH Record ==\r\n'
		for k in self.__dict__:
			if isinstance(self.__dict__[k], list):
				for i, item in enumerate(self.__dict__[k]):
					t += '   %s: %s: %s' % (k, i, str(item))
			else:
				t += '%s: %s \r\n' % (k, str(self.__dict__[k]))
		return t