
"""
Der vk-Record
=============

Offset	Size	Contents
0x0000	Word	ID: ASCII-"vk" = 0x6B76
0x0002	Word	name length
0x0004	D-Word	length of the data
0x0008	D-Word	Offset of Data
0x000C	D-Word	Type of value
0x0010	Word	Flag
0x0012	Word	Unused (data-trash)
0x0014	????	Name

If bit 0 of the flag-word is set, a name is present, otherwise the
value has no name (=default)
If the data-size is lower 5, the data-offset value is used to store
the data itself!
"""
import io
import enum

class REGTYPE(enum.Enum):
	REG_NONE = 0
	REG_SZ = 1
	REG_EXPAND_SZ = 2
	REG_BINARY = 3
	REG_DWORD =4
	REG_DWORD_BIG_ENDIAN = 5
	REG_LINK = 6
	REG_MULTI_SZ = 7 
	REG_RESOURCE_LIST = 8  
	REG_FULL_RESOURCE_DESCRIPTOR = 9
	REG_RESOURCE_REQUIREMENTS_LIST = 10
	REG_QWORD = 11

class NTRegistryVK:
	def __init__(self):
		self.magic = b'vk'
		self.name_length = None
		self.data_length = None
		self.offset_data = None
		self.value_type = None
		self.flag = None
		self.unused = None
		self.name = None
		
		####
		self.data = None
		
	def load_data(self, reader, is_file = True):
		if self.data_length == 0:
			return b''
		elif self.data_length < 5:
			return self.offset_data
		else:
			if is_file is True:
				reader.seek(self.offset_data+ 4 + 4096)
			else:
				reader.seek(self.offset_data+ 4)
			self.data = reader.read(self.data_length+4) ###??? +4
			return self.data
			

		

	@staticmethod
	def from_bytes(data):
		return NTRegistryVK.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		vk = NTRegistryVK()
		vk.magic = buff.read(2)
		vk.name_length = int.from_bytes(buff.read(2), 'little', signed = False)
		vk.data_length = int.from_bytes(buff.read(4), 'little', signed = True)
		vk.offset_data = int.from_bytes(buff.read(4), 'little', signed = False)
		
		t = int.from_bytes(buff.read(4), 'little', signed = False)
		if t in [e.value for e in REGTYPE]:
			vk.value_type = REGTYPE(t)
		else:
			vk.value_type = t

		vk.flag = int.from_bytes(buff.read(2), 'little', signed = False)
		vk.unused = int.from_bytes(buff.read(2), 'little', signed = False)
		vk.name = buff.read(vk.name_length)

		return vk

	def __str__(self):
		t = '== NT Registry VK block ==\r\n'
		for k in self.__dict__:
			t += '%s: %s \r\n' % (k, self.__dict__[k])
		return t
