

"""
the Value-List
==============

Offset	Size	Contents
0x0000	D-Word	Offset 1st Value
0x0004	D-Word	Offset 2nd Value
0x????	D-Word	Offset nth Value

To determine the number of values, you have to look at the
owner-nk-record!
"""
import io

class ValueList:
	def __init__(self):
		self.record_offsets = []
	
	@staticmethod
	def load_data_from_offset(reader, offset, size, is_file = True):
		if is_file is True:
			reader.seek(4096+offset, 0)
		else:
			reader.seek(offset,0)
		return ValueList.from_buffer(reader, size)

	@staticmethod
	async def aload_data_from_offset(reader, offset, size, is_file = True):
		if is_file is True:
			await reader.seek(4096+offset, 0)
		else:
			await reader.seek(offset,0)

		sk = ValueList()
		for _ in range(size):
			t = await reader.read(4)
			sk.record_offsets.append(int.from_bytes(t, 'little', signed = True))
		return sk
		
	
	@staticmethod
	def from_bytes(data, size):
		"""
		size is needed, because the struct doesnt contain its size!!
		"""
		return ValueList.from_buffer(io.BytesIO(data), size)

	@staticmethod
	def from_buffer(buff, size):
		sk = ValueList()
		for _ in range(size):
			sk.record_offsets.append(int.from_bytes(buff.read(4), 'little', signed = True))
		return sk

	def __str__(self):
		t = '== NT Registry Value list ==\r\n'
		for k in self.__dict__:
			if isinstance(self.__dict__[k], list):
				for i, item in enumerate(self.__dict__[k]):
					t += '   %s: %s: %s' % (k, i, str(item))
			else:
				t += '%s: %s \r\n' % (k, str(self.__dict__[k]))
		return t